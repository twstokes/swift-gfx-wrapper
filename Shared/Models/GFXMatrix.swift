import Foundation

/// Subclassable matrix that uses the Adafruit GFX library to draw to an array of `GFXPixel`s.
public class GFXMatrix {
    public let rows, cols: Int
    
    private lazy var pixels = (0..<cols*rows).map { _ in GFXPixel() }
    // array of pixels to clear before a new draw
    private var previousPixels: [GFXPixel] = []
    // wrapped Adafruit GFX matrix
    private let flipDotMatrix: VirtualDotMatrixWrapper
    // block to be fired for each frame step
    private var frameBlock: (() -> Void)?

    public init(rows: Int, cols: Int) {
        guard let flipDotMatrix = VirtualDotMatrixWrapper(cols, height: rows) else {
            fatalError()
        }
        
        self.rows = rows
        self.cols = cols
        self.flipDotMatrix = flipDotMatrix

        let selfPtr = bridge(obj: self)
        
        // since we can't capture context with closures passed to C,
        // we have to pass a `const void *` that is a pointer to this object (selfPtr)
        flipDotMatrix.start(selfPtr) { x, y, c, selfPtr in
            guard let selfPtr = selfPtr else {
                fatalError()
            }
            
            let boardSelf: GFXMatrix = bridge(ptr: selfPtr)
            boardSelf.draw(x: Int(x), y: Int(y), color: Int(c))
        }
    }
    
    // MARK: Private functions
    private func draw(x: Int, y: Int, color: Int) {
        let dot = self.pixels[x + y * self.cols]
        dot.color = color
        self.previousPixels.append(dot)
    }
    
    private func clearPixels() {
        self.previousPixels.forEach { $0.color = 0 }
        self.previousPixels.removeAll()
    }
    
    private func stopRoutine() {
        frameBlock = nil
    }
    
    // MARK: Public functions
    public func getPixelAt(row: Int, col: Int) -> GFXPixel? {
        let idx = row*cols + col

        guard idx >= 0, idx < self.rows * self.cols else {
            return nil
        }
        
        return self.pixels[idx]
    }
    
    // a step is a complete frame, typically driven by
    // a timing device (e.g. DisplayLink)
    public func step() {
        self.frameBlock?()
    }
    
    // MARK: Graphics routines
    public func flipFlop() {
        var flipped = false
        
        frameBlock = { [weak self] in
            guard let self = self else {
                return
            }
            
            let m = self.flipDotMatrix
            
            m.fillScreen(flipped ? Int32.max : 0)
            flipped.toggle()
        }
    }
    
    public func scrollText(text: String, color: Colorable, font: Font = Font.DefaultFont) {
        flipDotMatrix.setTextWrap(false)
        flipDotMatrix.setTextColor(color.to565())
        flipDotMatrix.setFont(font)

        var x = self.cols
        var x1 = Int16(0), y1 = Int16(0), w = UInt16(0), h = UInt16(0)
        
        self.flipDotMatrix.getTextBoundsPtr(text, x: x, y: 5, x1: &x1, y1: &y1, width: &w, height: &h)
        
        let width = Int(w)
        
        frameBlock = { [weak self] in
            guard let self = self else {
                return
            }
            
            let m = self.flipDotMatrix

            self.clearPixels()
            m.setCursor(x, height: 3)
            m.print(text)

            x = x - 1
            
            if (x < -width) {
                x = self.cols
            }
        }
    }
}

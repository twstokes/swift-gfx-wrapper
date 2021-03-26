import Foundation

/// Subclassable matrix that uses the Adafruit GFX library to draw to an array of `GFXPixel`s.
open class GFXMatrix {
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
    open func getPixelAt(row: Int, col: Int) -> GFXPixel? {
        let idx = row*cols + col

        guard idx >= 0, idx < self.rows * self.cols else {
            return nil
        }
        
        return self.pixels[idx]
    }
    
    // a step is a complete frame, typically driven by
    // a timing device (e.g. DisplayLink)
    open func step() {
        self.frameBlock?()
    }
    
    // MARK: Graphics routines
    open func flipFlop() {
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
    
    /// Scrolls text in the middle of the matrix infinitely.
    /// 
    /// - Parameters:
    ///   - text: String to output.
    ///   - font: Font to use.
    ///   - size: Font size.
    ///   - color: Color to use.
    ///   - verticalOffset: Vertical offset from middle.
    open func scrollText(
        text: String,
        font: Font? = nil,
        size: Int = 1,
        color: Colorable? = nil,
        verticalOffset: Int = 0
    ) {
        flipDotMatrix.setTextWrap(false)
        flipDotMatrix.setTextSize(size)
        
        if let font = font {
            flipDotMatrix.setFont(font)
        }
        
        if let color = color {
            flipDotMatrix.setTextColor(color.to565())
        }

        var x = cols
        var x1 = Int16(0), y1 = Int16(0), w = UInt16(0), h = UInt16(0)
        
        self.flipDotMatrix.getTextBoundsPtr(text, x: x, y: flipDotMatrix.getCursorY(), x1: &x1, y1: &y1, width: &w, height: &h)
        
        /*
            compute the vertical middle taking into account that custom fonts use
            a different baseline than the default font
            
            Adafruit docs:
            For example, whereas the cursor position when printing with the classic font identified the top-left corner of
            the character cell, with new fonts the cursor position indicates the baseline — the bottom-most row — of
            subsequent text.
        */
        let verticalMiddle = flipDotMatrix.getCursorY() - Int(y1) + (rows / 2) - (Int(h) / 2)
        let width = Int(w)
        
        frameBlock = { [weak self] in
            guard let self = self else {
                return
            }
            
            let m = self.flipDotMatrix

            self.clearPixels()
            m.setCursor(x, y: verticalMiddle + verticalOffset)
            m.print(text)

            x = x - 1
            
            if (x < -width) {
                x = self.cols
            }
        }
    }
}

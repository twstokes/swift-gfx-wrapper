import Foundation

/// Subclassable matrix that uses the Adafruit GFX library.
open class GFXMatrix: VirtualDotMatrixWrapper {
    // callback signature used to retrieve pixel writes from the Adafruit GFX Library
    public typealias DrawCallback = (_ x: Int, _ y: Int, _ color: Int) -> Void
    
    // block to be fired for a single complete frame
    // this can be replaced while the matrix is running
    // to present new sequences
    private var frameBlock: (() -> Void)?
    
    // callback to be fired for each pixel write
    // this will typically be called multiple times to write all of the pixels
    // of a single frame
    private var drawCallback: DrawCallback?
    
    public init(rows: Int, cols: Int, drawCallback: @escaping (DrawCallback)) {
        self.drawCallback = drawCallback
        super.init(cols, height: rows)
        
        // since we can't capture context with closures passed to C,
        // we have to pass a `const void *` that is a pointer to this object (selfPtr)
        let selfPtr = bridge(obj: self)

        // this callback serves as syntatic sugar for the `drawCallback`
        start(selfPtr) { x, y, c, selfPtr in
            guard let selfPtr = selfPtr else {
                fatalError()
            }
            
            let matrixSelf: GFXMatrix = bridge(ptr: selfPtr)
            matrixSelf.drawCallback?(Int(x), Int(y), Int(c))
        }
    }
    
    // set a new block to run when the frame is computed
    // set to nil to clear the frame block
    public func setFrameBlock(_ block: (() -> Void)?) {
        frameBlock = block
    }

    // a step is a complete frame, typically driven by
    // a timing device (e.g. DisplayLink)
    public func step() {
        frameBlock?()
    }
}

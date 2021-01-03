import Foundation

/// Handles driving each frame computed for a GFXBoard.
public protocol GFXFrameDriver {
    func setFrameBlock(block: @escaping (() -> Void))
    func setFrameRate(fps: Int)
}

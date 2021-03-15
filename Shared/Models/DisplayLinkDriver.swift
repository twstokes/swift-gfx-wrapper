#if os(iOS)
import Foundation
import UIKit

/// `GFXFrameDriver` conformance for `DisplayLinkDriver`.
public class DisplayLinkDriver: GFXFrameDriver {
    private var displayLink: CADisplayLink?
    private var frameBlock: (() -> Void)?
    
    public init() {
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFramesPerSecond = 10
        displayLink.add(to: .current, forMode: .common)
        
        self.displayLink = displayLink
    }
    
    public func setFrameRate(fps: Int) {
        displayLink?.preferredFramesPerSecond = fps
    }
    
    public func setFrameBlock(block: @escaping (() -> Void)) {
        frameBlock = block
    }
    
    @objc func step() {
        frameBlock?()
    }
}
#endif

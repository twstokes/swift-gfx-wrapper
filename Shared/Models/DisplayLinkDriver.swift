#if os(iOS)
import Foundation
import UIKit

/// `GFXFrameDriver` conformance for `DisplayLinkDriver`.
open class DisplayLinkDriver: GFXFrameDriver {
    private var displayLink: CADisplayLink?
    private var stepBlock: (() -> Void)?
        
    public init() {
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFramesPerSecond = 10
        
        
        self.displayLink = displayLink
    }
    
    open func setFrameRate(fps: Int) {
        displayLink?.preferredFramesPerSecond = fps
    }
    
    open func setStepBlock(_ block: (() -> Void)?) {
        stepBlock = block
    }
    
    open func start() {
        displayLink?.add(to: .current, forMode: .common)
    }
    
    open func pause() {
        displayLink?.isPaused = true
    }
    
    open func resume() {
        displayLink?.isPaused = false
    }
    
    open func stop() {
        stepBlock = nil
        displayLink?.remove(from: .current, forMode: .common)
    }
    
    @objc private func step() {
        stepBlock?()
    }
}
#endif

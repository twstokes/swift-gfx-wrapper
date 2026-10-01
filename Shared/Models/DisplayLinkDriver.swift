#if os(iOS)
    import Foundation
    import UIKit

    /// Drives frames at the display's native cadence unless a rate is requested.
    open class DisplayLinkDriver: GFXFrameDriver {
        // CADisplayLink retains its target. A weak proxy lets owners deallocate
        // the driver without leaving a live display link on the run loop.
        private class Target: NSObject {
            weak var driver: DisplayLinkDriver?

            @objc func step() {
                driver?.stepBlock?()
            }
        }

        private let target = Target()
        private var displayLink: CADisplayLink?
        private var stepBlock: (() -> Void)?
        private weak var windowScene: UIWindowScene?
        private var requestedFPS = 0
        private var running = false
        private var paused = false

        public init() {
            target.driver = self
        }

        deinit {
            displayLink?.invalidate()
        }

        /// Bind to the window displaying the content, including external screens.
        /// Rebinding preserves the running/paused state and the requested rate.
        open func setWindowScene(_ scene: UIWindowScene) {
            guard windowScene !== scene else { return }
            windowScene = scene
            displayLink?.invalidate()
            displayLink = nil
            if running { scheduleDisplayLink() }
        }

        /// Zero follows native display cadence; positive values request a rate.
        open func setFrameRate(fps: Int) {
            precondition(fps >= 0, "Frame rate must be nonnegative")
            requestedFPS = fps
            configureFrameRate()
        }

        private func configureFrameRate() {
            guard let displayLink = displayLink else { return }
            if #available(iOS 15.0, *) {
                if requestedFPS == 0 {
                    displayLink.preferredFrameRateRange = .default
                } else {
                    let fps = Float(min(requestedFPS, windowScene?.screen.maximumFramesPerSecond ?? requestedFPS))
                    displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: fps, maximum: fps, preferred: fps)
                }
            } else {
                displayLink.preferredFramesPerSecond = requestedFPS
            }
        }

        private func scheduleDisplayLink() {
            let selector = #selector(Target.step)
            if let scene = windowScene {
                if #available(iOS 27.0, *) {
                    displayLink = scene.displayLink(target: target, selector: selector)
                } else {
                    displayLink = scene.screen.displayLink(withTarget: target, selector: selector)
                }
            } else {
                displayLink = CADisplayLink(target: target, selector: selector)
            }
            configureFrameRate()
            displayLink?.isPaused = paused
            displayLink?.add(to: .main, forMode: .common)
        }

        open func setStepBlock(_ block: (() -> Void)?) {
            stepBlock = block
        }

        open func start() {
            guard !running else { return }
            running = true
            scheduleDisplayLink()
        }

        open func pause() {
            paused = true
            displayLink?.isPaused = true
        }

        open func resume() {
            paused = false
            displayLink?.isPaused = false
        }

        open func stop() {
            stepBlock = nil
            displayLink?.invalidate()
            displayLink = nil
            running = false
            paused = false
        }
    }
#endif

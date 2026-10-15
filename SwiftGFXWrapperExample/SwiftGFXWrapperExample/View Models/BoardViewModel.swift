import Foundation
import SwiftUI
import UIKit

import SwiftGFXWrapper

class BoardViewModel: ObservableObject {
    @Published private(set) var frame: CGImage?

    // Public to make Playground access convenient
    let matrix: GFXMatrix
    private let driver = DisplayLinkDriver()
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private var displayedRevision: UInt64?

    var rows: Int {
        matrix.height()
    }

    var cols: Int {
        matrix.width()
    }

    init(rows: Int, cols: Int) {
        matrix = GFXMatrix(rows: rows, cols: cols)
        updateFrame()

        driver.setStepBlock { [weak self] in
            guard let self = self else { return }
            self.matrix.step()
            self.updateFrame()
        }

        // example of an included graphics routine to scroll text
        matrix.scrollText(text: "Hello!", color: UIColor.orange)

        // example of a local graphics routine to manipulate the matrix
//         bouncyBox()

    }

    func attach(to scene: UIWindowScene?) {
        guard let scene = scene else {
            driver.pause()
            return
        }
        driver.setWindowScene(scene)
        driver.start()
        driver.resume()
    }

    deinit {
        driver.stop()
    }

    private func updateFrame() {
        let revision = matrix.frameRevision()
        guard displayedRevision != revision else { return }
        guard let data = matrix.rgbaFrame(),
              let provider = CGDataProvider(data: data as CFData) else { return }
        frame = CGImage(width: cols, height: rows, bitsPerComponent: 8,
                        bitsPerPixel: 32, bytesPerRow: cols * 4,
                        space: colorSpace,
                        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                        provider: provider, decode: nil, shouldInterpolate: false,
                        intent: .defaultIntent)
        if frame != nil { displayedRevision = revision }
    }

    private func bouncyBox() {
        var x = Int.random(in: 0 ..< matrix.width())
        var y = Int.random(in: 0 ..< matrix.height())
        var addingX = false
        var addingY = false

        matrix.setFrameBlock {
            self.matrix.fillScreen(0)
            self.matrix.drawPixel(x, y: y, color: UIColor.green.to565())

            if x >= self.matrix.width() - 1 || x <= 0 {
                addingX.toggle()
            }

            if y >= self.matrix.height() - 1 || y <= 0 {
                addingY.toggle()
            }

            x = addingX ? x + 1 : x - 1
            y = addingY ? y + 1 : y - 1
        }
    }
}

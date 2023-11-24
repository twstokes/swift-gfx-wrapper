import Foundation
import SwiftUI
import UIKit

import SwiftGFXWrapper

class BoardViewModel {
    private let matrix: GFXMatrix
    private var pixels: [PixelData]

    var rows: Int {
        matrix.height()
    }
    
    var cols: Int {
        matrix.width()
    }

    var bufferWrite: (([PixelData]) -> Void)?

    init(rows: Int, cols: Int) {
        // a buffer to track our pixel state
        pixels = (0..<cols*rows).map { _ in PixelData(from: 0) }

        // create a new matrix
        matrix = GFXMatrix(rows: rows, cols: cols)
        
        // set the function that's fired on every pixel draw
        matrix.setDrawCallback { [self] x, y, color in
            pixels[x + y * cols] = PixelData(from: color)
        }
        
//        // use a frame driver to handle the timing of each frame
//        let driver = DisplayLinkDriver()
//        // tell the driver what function to call on every frame step
//        driver.setStepBlock { [weak self] in
//            guard let self else { return }
//            matrix.step()
//            bufferWrite?(pixels)
//        }

        // example of an included graphics routine to scroll text
        matrix.scrollText(text: "Hello!", color: UIColor.orange)

        // example of a local graphics routine to manipulate the matrix
        // bouncyBox()

        // start the driver
//        driver.start()
    }

    func generateFrame() -> [PixelData] {
        matrix.step()
        return pixels
    }

    private func bouncyBox() {
        var x = 0
        var y = 0
        var addingX = false
        var addingY = false
        
        matrix.setFrameBlock { [weak self] in
            guard let self else { return }
            
            matrix.fillScreen(0)
            matrix.drawPixel(x, y: y, color: UIColor.green.to565())

            if x >= matrix.width() - 1 || x <= 0 {
                addingX.toggle()
            }

            if y >= matrix.height() - 1 || y <= 0 {
                addingY.toggle()
            }
            
            x = addingX ? x+1 : x-1
            y = addingY ? y+1 : y-1
        }
    }
}

struct PixelData {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8 = 255

    init(from int565: Int) {
        red = UInt8((int565 & 0xF800) >> 11).scaleTo255(max: 32)
        green = UInt8((int565 & 0x7E0) >> 5).scaleTo255(max: 64)
        blue = UInt8((int565 & 0x1F)).scaleTo255(max: 32)
    }

    var bytes: [UInt8] {
        return [red, green, blue, alpha]
    }
}

extension UInt8 {
    func scaleTo255(max: UInt8) -> UInt8 {
        guard max > 0 else {
            return 0
        }

        let ratio = Float(self) / Float(max)
        return UInt8(Float(255) * ratio)
    }
}

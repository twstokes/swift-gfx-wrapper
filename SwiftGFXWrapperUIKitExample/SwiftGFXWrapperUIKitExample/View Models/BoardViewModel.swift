import Foundation
import UIKit

import SwiftGFXWrapper

struct BoardViewModel {
    private let matrix: GFXMatrix
    private let bufferCallback: (([Pixel]) -> ())
    var pixels: [Pixel]
    
    var rows: Int {
        matrix.height()
    }
    
    var cols: Int {
        matrix.width()
    }
    
    init(rows: Int, cols: Int, bufferCallback: @escaping (([Pixel]) -> ())) {
        // a buffer to track our pixel state
        pixels = (0..<cols*rows).map { _ in Pixel() }
        self.bufferCallback = bufferCallback
        
        // create a new matrix
        matrix = GFXMatrix(rows: rows, cols: cols)
        
        // set the function that's fired on every pixel draw
        matrix.setDrawCallback { [self] x, y, color in
            pixels[x + y * cols].color = UIColor(color)
        }
        
        // use a frame driver to handle the timing of each frame
        let driver = DisplayLinkDriver()
        // tell the driver what function to call on every frame step
        driver.setStepBlock(step)

        // example of an included graphics routine to scroll text
        matrix.scrollText(text: "Hello!", color: UIColor.orange)
        
        // example of a local graphics routine to manipulate the matrix
        // bouncyBox()
        
        // start the driver
        driver.start()
    }

    func step() {
        matrix.step()
        bufferCallback(pixels)
    }
    
    func getPixelAt(row: Int, col: Int) -> Pixel? {
        let idx = row*matrix.width() + col
        
        guard pixels.indices.contains(idx) else {
            return nil
        }

        return pixels[idx]
    }
    
    private func bouncyBox() {
        var x = 0
        var y = 0
        var addingX = false
        var addingY = false
        
        matrix.setFrameBlock {
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

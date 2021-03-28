import Foundation
import UIKit

import SwiftGFXWrapper

class BoardViewModel {
    private let matrix: GFXMatrix
    private let buffer: [Pixel]
    
    var rows: Int {
        matrix.height()
    }
    
    var cols: Int {
        matrix.width()
    }
    
    init(rows: Int, cols: Int) {
        let buffer = (0..<cols*rows).map { _ in Pixel() }
        
        // this is the closure that "draws" to the data structure tracking the pixel buffer
        self.matrix = GFXMatrix(rows: rows, cols: cols) { x, y, color in
            let dot = buffer[x + y * cols]
            
            // increase performance by doing minimal work
            if dot.color != color {
                dot.color = color
            }
        }
        
        self.buffer = buffer
        
        // use a frame driver to handle the timing of each frame
        let driver = DisplayLinkDriver()
        // tell the driver what function to call on every frame step
        driver.setStepBlock(matrix.step)

        // example of an included graphics routine to scroll text
        matrix.scrollText(text: "Hello!", color: UIColor.orange)
        
        // example of a local graphics routine to manipulate the matrix
        // bouncyBoxes()
        
        // start the driver
        driver.start()
    }
    
    func getPixelAt(row: Int, col: Int) -> Pixel? {
        let idx = row*matrix.width() + col

        guard idx >= 0, idx < matrix.height() * matrix.width() else {
            return nil
        }

        return self.buffer[idx]
    }
    
    private func bouncyBoxes() {
        var x = 0
        var y = 0
        var addingX = true
        var addingY = true
        
        matrix.setFrameBlock { [unowned self] in
            matrix.fillScreen(0)
            matrix.drawPixel(x, y: y, color: UIColor.green.to565())
            
            if x >= matrix.width() - 1 || x <= 0 {
                addingX.toggle()
            }
            
            if y >= matrix.height() - 1 || y <= 0 {
                addingY.toggle()
            }
            
            x = addingX ? x-1 : x+1
            y = addingY ? y-1 : y+1
        }
    }
}

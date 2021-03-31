import Foundation
import UIKit

import SwiftGFXWrapper

class BoardViewModel {
    private let matrix: ExampleMatrix
        
    var rows: Int {
        matrix.height()
    }
    
    var cols: Int {
        matrix.width()
    }
    
    init(rows: Int, cols: Int) {
        // create a new matrix
        matrix = ExampleMatrix(rows: rows, cols: cols)
                
        // use a frame driver to handle the timing of each frame
        let driver = DisplayLinkDriver()
        // tell the driver what function to call on every frame step
        driver.setStepBlock(matrix.step)

        // example of an included graphics routine to scroll text
        matrix.scrollText(text: "Hello!", color: UIColor.orange)
        
        // example of a local graphics routine to manipulate the matrix
        // bouncyBox()
        
        // start the driver
        driver.start()
    }
    
    func getPixelAt(row: Int, col: Int) -> Pixel? {
        return matrix.getPixelAt(row: row, col: col)
    }
    
    private func bouncyBox() {
        var x = 0
        var y = 0
        var addingX = false
        var addingY = false
        
        matrix.setFrameBlock { [unowned self] in
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

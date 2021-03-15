import Foundation
import UIKit

import SwiftGFXWrapper

class BoardViewModel {
    let matrix: GFXMatrix
    
    init(rows: Int, cols: Int, driver: GFXFrameDriver) {
        self.matrix = GFXMatrix(rows: rows, cols: cols)
        
        driver.setFrameBlock { [weak self] in
            self?.matrix.step()
        }
        
        self.matrix.scrollText(text: "Hello!", color: UIColor.green)
    }
}

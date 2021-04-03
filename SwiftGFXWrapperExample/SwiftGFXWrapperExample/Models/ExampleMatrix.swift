import Foundation

import SwiftGFXWrapper

class ExampleMatrix: GFXMatrix {
    private var buffer = Set<Pixel>()
    
    override init(rows: Int, cols: Int) {
        super.init(rows: rows, cols: cols)
        
        // a buffer to track our pixel state
        for r in 0..<rows {
            for c in 0..<cols {
                buffer.insert(Pixel(x: c, y: r))
            }
        }
        
        // set the function that's fired on every pixel draw
        setDrawCallback { x, y, color in
            guard let dot = self.buffer.first(
                where: { $0.x == x && $0.y == y }
            ) else {
                return
            }

            if dot.color != color {
                dot.color = color
            }
        }
    }
    
    // a performance optimized version of fillScreen
    // for our application
    override func fillScreen(_ c: Int32) {
        buffer
            .filter { $0.color != Int(c) }
            .forEach { $0.color = Int(c) }
    }
    
    func getPixelAt(row: Int, col: Int) -> Pixel? {
        buffer.first(where: { $0.x == col && $0.y == row })
    }
}

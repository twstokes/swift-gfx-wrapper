import Foundation

import SwiftGFXWrapper

class ExampleMatrix: GFXMatrix {
    var buffer = Set<Pixel>()
    
    override init(rows: Int, cols: Int) {
        super.init(rows: rows, cols: cols)
        
        // a buffer to track our pixel state
        for r in 0..<rows {
            for c in 0..<cols {
                buffer.insert(Pixel(x: c, y: r))
            }
        }
        
        // set the function that's fired on every pixel draw
        setDrawCallback { [self] x, y, color in
            guard let dot = buffer.first(
                    where: { $0.x == x && $0.y == y && $0.color != color }
            ) else {
                return
            }
           
            dot.color = color
        }
    }
    
    override func fillScreen(_ c: Int32) {
        // a performance optimized version of fillScreen
        // for our application
        buffer
            .filter { $0.color != Int(c) }
            .forEach { $0.color = Int(c) }
    }
    
    func getPixelAt(row: Int, col: Int) -> Pixel? {
        buffer.first(where: { $0.x == col && $0.y == row })
    }
}

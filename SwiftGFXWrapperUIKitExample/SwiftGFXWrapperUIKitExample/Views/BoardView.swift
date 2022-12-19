import Foundation
import UIKit

class BoardView: UIView {
    private var rows: Int?
    private var cols: Int?
    private var buffer: [Pixel]?

    convenience init(rows: Int, cols: Int) {
        self.init()

        self.rows = rows
        self.cols = cols
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        guard let rows = rows, let cols = cols else { return }
        guard let buffer = buffer else { return }


        let pixelSize = BoardView.getRectSizeForPixel(rows: rows, cols: cols, frameSize: frame.size)

        for row in 0..<rows {
            for col in 0..<cols {
                let pixel = BoardView.getPixelAt(row: row, col: col, cols: cols, buffer: buffer)

                if pixel.color == .black { continue }

                ctx.setStrokeColor(pixel.color.cgColor)
                ctx.setFillColor(pixel.color.cgColor)

                let pixelRect = CGRect(
                    origin: .init(
                        x: pixelSize.width * CGFloat(col),
                        y: pixelSize.height * CGFloat(row)),
                    size: pixelSize.insetBy(
                        width: pixelSize.width * 0.1,
                        height: pixelSize.height * 0.1
                    )
                )

                ctx.fill(pixelRect)
            }
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let rows = rows, let cols = cols else { return .zero }

        let maxBoardDim = max(rows, cols)
        let minRectDim = min(size.width, size.height)




//        let aspectRatio = CGFloat(rows / cols)
//        let aspectWidth = size.width * aspectRatio
//        let aspectHeight = size.height * aspectRatio

        // TODO - figure out how to fit it within the given size with the correct aspect ratio

//        let minDim = min(aspectWidth, aspectHeight)

//        let minDim = min(rows, cols)
//        let minSizeDim = min(size.width, size.height)


//        return .init(width: size.width * CGFloat(aspectRatio), height: size.height * CGFloat(aspectRatio))
        return .zero
    }

    static func getRectSizeForPixel(rows: Int, cols: Int, frameSize: CGSize) -> CGSize {
        let height = frameSize.height / CGFloat(rows)
        let width = frameSize.width / CGFloat(cols)

        return CGSize(width: width, height: height)
    }

    static func getPixelAt(row: Int, col: Int, cols: Int, buffer: [Pixel]) -> Pixel {
        return buffer[cols * row + col]
    }

    func updateBoard(pixels: [Pixel]) {
        guard let rows = rows, let cols = cols else { return}

        guard pixels.count == rows * cols else {
            print("Buffer receieved didn't match expected size!")
            return
        }

        print("Updating board with pixels. \(pixels.count)")
        buffer = pixels
        setNeedsDisplay()
    }
}

extension CGSize {
    func insetBy(width: CGFloat, height: CGFloat) -> CGSize {
        return .init(width: self.width - width, height: self.height - height)
    }
}

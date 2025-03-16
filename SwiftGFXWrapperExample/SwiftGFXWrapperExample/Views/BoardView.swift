import SwiftUI

import SwiftGFXWrapper

struct BoardView: View {
    static private let rows = 14, cols = 28
    @StateObject var vm = BoardViewModel(rows: rows, cols: cols)

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let cellSize = size.width / CGFloat(BoardView.cols)
                let spacing = cellSize * 0.1

                for row in 0..<vm.rows {
                    for col in 0..<vm.cols {
                        if let pixel = vm.getPixelAt(row: row, col: col) {
                            let rect = CGRect(
                                x: CGFloat(col) * cellSize,
                                y: CGFloat(row) * cellSize,
                                width: cellSize - spacing,
                                height: cellSize - spacing
                            )
                            context.fill(Path(rect), with: .color(pixel))
                        }
                    }
                }
            }.background(Color.gray.opacity(0.3))
        }.aspectRatio(
            .init(width: BoardView.cols, height: BoardView.rows),
            contentMode: .fit
        )
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}


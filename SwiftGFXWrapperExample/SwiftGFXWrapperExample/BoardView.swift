import SwiftUI
import SwiftGFXWrapper

struct BoardView: View {
    private let vm = BoardViewModel(rows: 16, cols: 32, driver: DisplayLinkDriver())

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: geo.size.width * 0.005) {
                Spacer()
                ForEach((0..<vm.matrix.rows), id: \.self) { row in
                    HStack(spacing: geo.size.width * 0.005) {
                        ForEach((0..<vm.matrix.cols), id: \.self) { col in
                            if let pixel = vm.matrix.getPixelAt(row: row, col: col) {
                                PixelView(pixel: pixel)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}


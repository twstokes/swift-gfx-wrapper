import SwiftUI

import SwiftGFXWrapper

public struct BoardView: View {
    private let vm = BoardViewModel(rows: 16, cols: 32)
    
    public init() {}

    public var body: some View {
        GeometryReader { geo in
            VStack(spacing: geo.size.width * 0.005) {
                Spacer()
                ForEach((0..<vm.rows)) { row in
                    HStack(spacing: geo.size.width * 0.005) {
                        ForEach((0..<vm.cols)) { col in
                            if let pixel = vm.getPixelAt(row: row, col: col) {
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

import UIKit
import SwiftUI
import PlaygroundSupport

import SwiftGFXWrapper

private let vm = BoardViewModel(rows: 16, cols: 32)

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
            BoardView()
        }.frame(width: 400, height: 200)
    }
}

PlaygroundPage.current.setLiveView(ContentView())

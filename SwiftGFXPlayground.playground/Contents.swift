import UIKit
import SwiftUI
import PlaygroundSupport

import SwiftGFXWrapper


struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
            BoardView()
        }.frame(width: 400, height: 200)
    }
}

PlaygroundPage.current.setLiveView(ContentView())

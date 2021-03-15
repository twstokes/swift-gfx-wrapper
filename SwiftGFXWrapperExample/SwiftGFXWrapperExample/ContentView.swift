import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
            BoardView()
        }
        .statusBar(hidden: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
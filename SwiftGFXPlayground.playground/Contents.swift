import UIKit
import SwiftUI
import PlaygroundSupport

import SwiftGFXWrapper


struct ContentView: View {
    private let vm = BoardViewModel(rows: 16, cols: 32)
    
    var body: some View {
        ZStack {
            Color.black
            BoardView(vm: vm)
        }
        .frame(width: 400, height: 400)
        .onAppear {
            let matrix = vm.matrix
            
            var x = 0
            var y = 0
            var addingX = false
            var addingY = false
            
            matrix.setFrameBlock {
                matrix.fillScreen(0)
                matrix.drawPixel(x, y: y, color: UIColor.green.to565())
                
                if x >= matrix.width() - 1 || x <= 0 {
                    addingX.toggle()
                }
                
                if y >= matrix.height() - 1 || y <= 0 {
                    addingY.toggle()
                }
                
                x = addingX ? x+1 : x-1
                y = addingY ? y+1 : y-1
            }
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())

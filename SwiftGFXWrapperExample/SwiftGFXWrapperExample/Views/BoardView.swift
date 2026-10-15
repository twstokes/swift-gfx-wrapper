import SwiftUI
import UIKit
import SwiftGFXWrapper

struct BoardView: View {
    @StateObject var vm = BoardViewModel(rows: 100, cols: 100)

    var body: some View {
        Group {
            if let frame = vm.frame {
                Image(decorative: frame, scale: 1)
                    .interpolation(.none)
                    .resizable()
            } else {
                Color.black
            }
        }
        .background(WindowSceneObserver { [weak vm] scene in
            vm?.attach(to: scene)
        })
        .aspectRatio(CGFloat(vm.cols) / CGFloat(vm.rows), contentMode: .fit)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}

// Read the screen from this view's window instead of assuming the main screen.
private struct WindowSceneObserver: UIViewRepresentable {
    let onChange: (UIWindowScene?) -> Void

    func makeUIView(context: Context) -> ObserverView {
        let view = ObserverView()
        view.isUserInteractionEnabled = false
        view.onChange = onChange
        return view
    }

    func updateUIView(_ view: ObserverView, context: Context) {
        view.onChange = onChange
    }

    final class ObserverView: UIView {
        var onChange: ((UIWindowScene?) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            onChange?(window?.windowScene)
        }
    }
}

import UIKit

class ViewController: UIViewController {
    private var boardView: BoardView?

    lazy var vm = BoardViewModel(rows: 32, cols: 32) {[weak self] buffer in
        guard let self = self else { return }
        self.drawBuffer(buffer: buffer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let boardView = BoardView(rows: vm.rows, cols: vm.cols)
        boardView.frame.size = boardView.sizeThatFits(view.frame.size)

        self.boardView = boardView
        view.addSubview(boardView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func drawBuffer(buffer: [Pixel]) {
        print("Got pixel buffer: \(buffer.count)")
        boardView?.updateBoard(pixels: buffer)
    }
}


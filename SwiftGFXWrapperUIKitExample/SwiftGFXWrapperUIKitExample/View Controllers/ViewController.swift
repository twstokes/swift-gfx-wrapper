import UIKit

class ViewController: UIViewController {
    private let vm = BoardViewModel(rows: 64, cols: 64) { buffer in
        print("Got pixel buffer: \(buffer.count)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func drawBuffer(buffer: [Pixel]) {
        print("Drawing a buffer!")
    }
}


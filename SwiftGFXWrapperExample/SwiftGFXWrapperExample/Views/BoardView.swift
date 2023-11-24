import SwiftUI

import SwiftGFXWrapper
import SpriteKit

struct BoardView: View {
    static private let rows = 100, cols = 100
    private let vm = BoardViewModel(rows: rows, cols: cols)

    var scene: BoardScene {
        let scene = BoardScene(size: CGSize(width: BoardView.cols, height: BoardView.rows))
        scene.vm = vm
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, preferredFramesPerSecond: 10)
            .aspectRatio(CGSize(width: BoardView.cols, height: BoardView.rows), contentMode: .fit)
            .ignoresSafeArea()
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}

class BoardScene: SKScene {
    private let node: SKSpriteNode
    var vm: BoardViewModel?

    override init(size: CGSize) {
        node = BoardScene.createNode(size: size)
        super.init(size: size)
        anchorPoint = .init(x: 0.5, y: 0.5)
        addChild(node)
        scaleMode = .fill
    }

    private static func createNode(size: CGSize) -> SKSpriteNode {
        let node = SKSpriteNode(color: .black, size: size)
        return node
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func recieveBuffer(_ pixels: [PixelData]) {
        let bytes = pixels.flatMap { $0.bytes }
        let data = Data(bytes)
        let texture = SKTexture(data: data, size: size, flipped: true)
        texture.filteringMode = .nearest
        node.texture = texture
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let pixels = vm?.generateFrame() {
            recieveBuffer(pixels)
        }
    }
}

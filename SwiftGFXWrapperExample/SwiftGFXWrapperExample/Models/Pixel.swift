import Foundation

/// Observable pixel drawn by a GFXMatrix.
class Pixel: ObservableObject, Identifiable, Hashable {
    @Published var color: Int = 0
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

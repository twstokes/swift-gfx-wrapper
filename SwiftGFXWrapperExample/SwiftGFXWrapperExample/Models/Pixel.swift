import Foundation

/// Observable pixel drawn by a GFXMatrix.
class Pixel: ObservableObject, Identifiable, Hashable, Equatable {
    @Published var color: Int = 0
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        lhs.id == rhs.id && lhs.color == rhs.color && lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(color)
        hasher.combine(x)
        hasher.combine(y)
    }
}

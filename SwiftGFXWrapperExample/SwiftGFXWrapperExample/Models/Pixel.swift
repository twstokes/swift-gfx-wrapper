import Foundation

/// Observable pixel drawn by a GFXMatrix.
class Pixel: ObservableObject, Identifiable {   
    @Published var color: Int = 0
}

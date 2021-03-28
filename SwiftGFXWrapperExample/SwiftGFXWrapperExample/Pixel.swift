import Foundation

/// Observable pixel driven by a GFXBoard.
class Pixel: ObservableObject, Identifiable {   
    @Published var color: Int = 0
}

import Foundation

/// Observable pixel driven by a GFXBoard.
public class GFXPixel: ObservableObject, Identifiable {
    @Published public var color: Int = 0
    
    public init() {}
}

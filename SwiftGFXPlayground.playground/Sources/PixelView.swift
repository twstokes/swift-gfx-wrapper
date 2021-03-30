import SwiftUI

import SwiftGFXWrapper

public struct PixelView: View {
    @ObservedObject public var pixel: Pixel

    public var body: some View {
        Rectangle()
            .foregroundColor(Color(pixel.color))
            .border(Color.gray.opacity(0.3))
            .scaledToFit()
    }
}

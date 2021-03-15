import SwiftUI

import SwiftGFXWrapper

struct PixelView: View {
    @ObservedObject var pixel: GFXPixel

    var body: some View {
        Rectangle()
            .foregroundColor(Color(pixel.color))
            .border(Color.gray.opacity(0.3))
            .scaledToFit()
    }
}

struct PixelView_Previews: PreviewProvider {
    static let pixel: GFXPixel = {
        let p = GFXPixel()
        p.color = Color.red.to565()
        return p
    }()
    
    static var previews: some View {
        PixelView(pixel: pixel)
    }
}

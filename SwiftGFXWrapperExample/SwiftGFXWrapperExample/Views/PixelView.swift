import SwiftUI

struct PixelView: View {
    @ObservedObject var pixel: Pixel

    var body: some View {
        Rectangle()
            .fill(Color(pixel.color))
            .border(Color.gray.opacity(0.3))
            .scaledToFit()
    }
}

struct PixelView_Previews: PreviewProvider {
    static let pixel: Pixel = {
        let p = Pixel()
        p.color = Color.red.to565()
        return p
    }()
    
    static var previews: some View {
        PixelView(pixel: pixel)
    }
}

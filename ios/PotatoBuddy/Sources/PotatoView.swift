import SwiftUI

/// Renders the current sprite frame with a pixel-grid `Canvas`.
///
/// Unlike AppKit (bottom-left origin, requiring a row flip), SwiftUI's
/// `Canvas` coordinate space grows downward, matching `PotatoSprite`'s
/// grid rows directly (row 0 = top of the sprite).
struct PotatoView: View {
    let expression: PotatoSprite.Expression
    let legPose: PotatoSprite.LegPose
    let facingRight: Bool

    var body: some View {
        Canvas { context, _ in
            let scale = PotatoSprite.scale
            for gy in 0..<PotatoSprite.gridHeight {
                for gx in 0..<PotatoSprite.gridWidth {
                    guard let color = PotatoSprite.color(
                        x: gx,
                        y: gy,
                        expression: expression,
                        legPose: legPose,
                        facingRight: facingRight
                    ) else { continue }

                    let rect = CGRect(
                        x: CGFloat(gx) * scale,
                        y: CGFloat(gy) * scale,
                        width: scale,
                        height: scale
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: PotatoSprite.pixelSize.width, height: PotatoSprite.pixelSize.height)
    }
}

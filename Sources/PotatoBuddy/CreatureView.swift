import Cocoa

/// Draws the current sprite frame and forwards drag gestures to the controller.
final class CreatureView: NSView {
    weak var controller: CreatureController?

    var expression: PotatoSprite.Expression = .normal
    var legPose: PotatoSprite.LegPose = .standing
    var facingRight: Bool = true

    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.setShouldAntialias(false)
        context.clear(bounds)

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

                // Grid row 0 is the top of the sprite; view origin is bottom-left.
                let viewY = CGFloat(PotatoSprite.gridHeight - 1 - gy) * scale
                let viewX = CGFloat(gx) * scale
                color.setFill()
                context.fill(CGRect(x: viewX, y: viewY, width: scale, height: scale))
            }
        }
    }

    override func mouseDown(with event: NSEvent) {
        controller?.beginDrag()
    }

    override func mouseDragged(with event: NSEvent) {
        controller?.continueDrag()
    }

    override func mouseUp(with event: NSEvent) {
        controller?.endDrag()
    }
}

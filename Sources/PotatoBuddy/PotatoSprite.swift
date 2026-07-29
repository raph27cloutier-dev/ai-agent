import AppKit

/// Procedural pixel-art sprite for the potato desktop creature.
///
/// Rather than hand-authoring pixel grids (easy to misalign and impossible
/// to eyeball-verify without a Mac to render on), the body silhouette is an
/// ellipse computed at draw time and cheap fixed offsets place the sprout,
/// eyes and legs. `color(x:y:...)` returns the pixel color for grid cell
/// (x, y), or nil for a transparent cell.
enum PotatoSprite {
    static let gridWidth = 16
    static let gridHeight = 14
    static let scale: CGFloat = 6

    static var pixelSize: NSSize {
        NSSize(width: CGFloat(gridWidth) * scale, height: CGFloat(gridHeight) * scale)
    }

    enum Expression: Equatable {
        case normal
        case blink
        case scared
        case surprised
    }

    enum LegPose: Equatable {
        case standing
        case stepA
        case stepB
    }

    private static let bodyCenterX: CGFloat = 7.5
    private static let bodyCenterY: CGFloat = 7.0
    private static let bodyRadiusX: CGFloat = 6.5
    private static let bodyRadiusY: CGFloat = 4.8

    private static let outline = NSColor(calibratedRed: 0.42, green: 0.26, blue: 0.13, alpha: 1)
    private static let base = NSColor(calibratedRed: 0.78, green: 0.53, blue: 0.26, alpha: 1)
    private static let highlight = NSColor(calibratedRed: 0.88, green: 0.66, blue: 0.41, alpha: 1)
    private static let shade = NSColor(calibratedRed: 0.61, green: 0.40, blue: 0.19, alpha: 1)
    private static let sproutDark = NSColor(calibratedRed: 0.18, green: 0.49, blue: 0.20, alpha: 1)
    private static let sproutLight = NSColor(calibratedRed: 0.30, green: 0.69, blue: 0.31, alpha: 1)
    private static let eyeColor = NSColor.black
    private static let legColor = NSColor(calibratedRed: 0.29, green: 0.17, blue: 0.09, alpha: 1)
    private static let blushColor = NSColor(calibratedRed: 0.85, green: 0.48, blue: 0.48, alpha: 1)

    /// Returns the fill color for grid cell (x, y), or nil if transparent.
    static func color(
        x: Int,
        y: Int,
        expression: Expression,
        legPose: LegPose,
        facingRight: Bool
    ) -> NSColor? {
        // Sprite is authored facing right; mirror the column when facing left.
        let gx = facingRight ? x : (gridWidth - 1 - x)

        if let sprout = sproutColor(gx: gx, y: y) { return sprout }
        if let exclaim = exclamationColor(gx: gx, y: y, expression: expression) { return exclaim }
        if let leg = legColorAt(gx: gx, y: y, legPose: legPose) { return leg }
        if let body = bodyColor(gx: gx, y: y, expression: expression) { return body }
        return nil
    }

    private static func sproutColor(gx: Int, y: Int) -> NSColor? {
        if y == 0 && gx == 8 { return sproutLight }
        if y == 1 && (gx == 7 || gx == 8) { return sproutDark }
        return nil
    }

    private static func exclamationColor(gx: Int, y: Int, expression: Expression) -> NSColor? {
        guard expression == .scared else { return nil }
        if gx == 12 && (y == 0 || y == 1) { return outline }
        if gx == 12 && y == 3 { return outline }
        return nil
    }

    private static func legColorAt(gx: Int, y: Int, legPose: LegPose) -> NSColor? {
        let leftCols = 4...5
        let rightCols = 9...10

        switch legPose {
        case .standing:
            if y == 12 && (leftCols.contains(gx) || rightCols.contains(gx)) { return legColor }
        case .stepA:
            if leftCols.contains(gx) && (y == 12 || y == 13) { return legColor }
            if rightCols.contains(gx) && y == 12 { return legColor }
        case .stepB:
            if rightCols.contains(gx) && (y == 12 || y == 13) { return legColor }
            if leftCols.contains(gx) && y == 12 { return legColor }
        }
        return nil
    }

    private static func bodyColor(gx: Int, y: Int, expression: Expression) -> NSColor? {
        let dx = (CGFloat(gx) + 0.5) - bodyCenterX
        let dy = (CGFloat(y) + 0.5) - bodyCenterY
        let normalized = (dx * dx) / (bodyRadiusX * bodyRadiusX) + (dy * dy) / (bodyRadiusY * bodyRadiusY)
        guard normalized <= 1.0 else { return nil }

        // Eyes (skipped on blink frames, enlarged when scared/surprised).
        let eyeRow = 6
        let leftEyeCol = 5
        let rightEyeCol = 10
        if expression != .blink {
            let eyeRows: [Int]
            switch expression {
            case .scared, .surprised:
                eyeRows = [eyeRow - 1, eyeRow]
            case .normal, .blink:
                eyeRows = [eyeRow]
            }
            if eyeRows.contains(y) && (gx == leftEyeCol || gx == rightEyeCol) {
                return eyeColor
            }
        }

        // Surprised mouth.
        if expression == .surprised && y == 9 && gx == bodyCenterXInt {
            return outline
        }

        // Blush when scared.
        if expression == .scared && y == 8 && (gx == 3 || gx == 12) {
            return blushColor
        }

        // Outline ring: cells inside the ellipse but close to its edge.
        if normalized > 0.72 { return outline }

        // Simple shading: lower-right quadrant a touch darker, upper-left highlighted.
        if dx < -1.0 && dy < -0.5 { return highlight }
        if dx > 1.5 && dy > 0.5 { return shade }
        return base
    }

    private static var bodyCenterXInt: Int { Int(bodyCenterX) }
}

import Cocoa

/// Owns the creature's window/view and drives its behavior: idling, walking
/// back and forth along the bottom of the screen, fleeing the cursor when it
/// gets close, and being picked up / dropped by dragging.
final class CreatureController {
    private enum State: Equatable {
        case idle
        case walking
        case fleeing
        case dragging
        case falling
    }

    private let window: CreatureWindow
    private let view: CreatureView
    private var timer: Timer?

    private var state: State = .idle
    private var facingRight = true
    private var ticksInState = 0
    private var stateTarget = 18
    private var legToggle = false

    private var blinkCountdown = Int.random(in: 30...90)
    private var isBlinking = false

    private var fallVelocity: CGFloat = 0

    private var dragAnchorMouse: NSPoint = .zero
    private var dragAnchorWindowOrigin: NSPoint = .zero

    private let tickInterval: TimeInterval = 1.0 / 12.0
    private let walkSpeed: CGFloat = 2.0
    private let fleeSpeed: CGFloat = 6.0
    private let fleeRadius: CGFloat = 160
    private let fleeVerticalRange: CGFloat = 220
    private let gravity: CGFloat = 1.6

    init() {
        window = CreatureWindow()
        view = CreatureView(frame: NSRect(origin: .zero, size: PotatoSprite.pixelSize))
        view.controller = self
        window.contentView = view
    }

    func start() {
        placeOnGround(atCenter: true)
        window.orderFrontRegardless()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    var isVisible: Bool { window.isVisible }

    func toggleVisibility() {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.orderFrontRegardless()
        }
    }

    func comeHere() {
        placeOnGround(atCenter: true)
        state = .idle
        ticksInState = 0
    }

    // MARK: - Dragging (called from CreatureView mouse events)

    func beginDrag() {
        state = .dragging
        fallVelocity = 0
        dragAnchorMouse = NSEvent.mouseLocation
        dragAnchorWindowOrigin = window.frame.origin
    }

    func continueDrag() {
        let current = NSEvent.mouseLocation
        let delta = NSPoint(
            x: current.x - dragAnchorMouse.x,
            y: current.y - dragAnchorMouse.y
        )
        window.setFrameOrigin(NSPoint(
            x: dragAnchorWindowOrigin.x + delta.x,
            y: dragAnchorWindowOrigin.y + delta.y
        ))
    }

    func endDrag() {
        let ground = groundY(for: window.screen ?? NSScreen.main)
        if window.frame.origin.y > ground + 1 {
            state = .falling
            fallVelocity = 0
        } else {
            snapToGround()
            state = .idle
            ticksInState = 0
        }
    }

    // MARK: - Behavior tick

    private func tick() {
        updateBlink()

        switch state {
        case .dragging:
            break
        case .falling:
            tickFalling()
        default:
            tickAutonomous()
        }

        view.facingRight = facingRight
        view.legPose = currentLegPose()
        view.expression = currentExpression()
        view.needsDisplay = true
    }

    private func updateBlink() {
        if isBlinking {
            blinkCountdown -= 1
            if blinkCountdown <= 0 {
                isBlinking = false
                blinkCountdown = Int.random(in: 40...110)
            }
        } else {
            blinkCountdown -= 1
            if blinkCountdown <= 0 {
                isBlinking = true
                blinkCountdown = 2
            }
        }
    }

    private func tickFalling() {
        guard let screen = window.screen ?? NSScreen.main else { return }
        fallVelocity -= gravity
        var newY = window.frame.origin.y + fallVelocity
        let ground = groundY(for: screen)
        if newY <= ground {
            newY = ground
            fallVelocity = 0
            state = .idle
            ticksInState = 0
        }
        window.setFrameOrigin(NSPoint(x: window.frame.origin.x, y: newY))
    }

    private func tickAutonomous() {
        guard let screen = window.screen ?? NSScreen.main else { return }

        if tryFlee(on: screen) { return }

        ticksInState += 1
        switch state {
        case .idle:
            if ticksInState > stateTarget {
                state = .walking
                facingRight = Bool.random()
                ticksInState = 0
                stateTarget = Int.random(in: 24...72)
            }
        case .walking:
            legToggle.toggle()
            step(speed: walkSpeed, on: screen)
            if ticksInState > stateTarget {
                state = .idle
                ticksInState = 0
                stateTarget = Int.random(in: 18...54)
            }
        default:
            break
        }
    }

    /// Switches to fleeing and moves away from the cursor if it's close and
    /// roughly at ground level. Returns true if fleeing handled this tick.
    private func tryFlee(on screen: NSScreen) -> Bool {
        let mouse = NSEvent.mouseLocation
        let center = NSPoint(x: window.frame.midX, y: window.frame.midY)
        let dx = mouse.x - center.x
        let dy = mouse.y - center.y
        let distance = (dx * dx + dy * dy).squareRoot()

        guard distance < fleeRadius, abs(dy) < fleeVerticalRange else {
            if state == .fleeing {
                state = .idle
                ticksInState = 0
                stateTarget = Int.random(in: 12...30)
            }
            return false
        }

        state = .fleeing
        facingRight = dx < 0
        legToggle.toggle()
        step(speed: fleeSpeed, on: screen)
        return true
    }

    private func step(speed: CGFloat, on screen: NSScreen) {
        let ground = groundY(for: screen)
        var newX = window.frame.origin.x + (facingRight ? speed : -speed)
        let minX = screen.frame.minX
        let maxX = screen.frame.maxX - window.frame.width

        if newX < minX {
            newX = minX
            facingRight = true
        } else if newX > maxX {
            newX = maxX
            facingRight = false
        }
        window.setFrameOrigin(NSPoint(x: newX, y: ground))
    }

    private func currentLegPose() -> PotatoSprite.LegPose {
        switch state {
        case .walking, .fleeing:
            return legToggle ? .stepA : .stepB
        case .idle, .dragging, .falling:
            return .standing
        }
    }

    private func currentExpression() -> PotatoSprite.Expression {
        switch state {
        case .dragging:
            return .surprised
        case .falling:
            return .surprised
        case .fleeing:
            return .scared
        case .idle, .walking:
            return isBlinking ? .blink : .normal
        }
    }

    // MARK: - Placement

    private func groundY(for screen: NSScreen?) -> CGFloat {
        // Sit right on top of the Dock (or screen bottom, if the Dock is hidden).
        (screen ?? NSScreen.main)?.visibleFrame.minY ?? 0
    }

    private func placeOnGround(atCenter: Bool) {
        guard let screen = NSScreen.main else { return }
        let ground = groundY(for: screen)
        let x: CGFloat
        if atCenter {
            x = screen.frame.midX - window.frame.width / 2
        } else {
            x = window.frame.origin.x
        }
        window.setFrameOrigin(NSPoint(x: x, y: ground))
    }

    private func snapToGround() {
        guard let screen = window.screen ?? NSScreen.main else { return }
        window.setFrameOrigin(NSPoint(x: window.frame.origin.x, y: groundY(for: screen)))
    }
}

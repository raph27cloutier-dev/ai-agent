import SwiftUI
import Combine

/// Drives the potato's behavior: idling, walking back and forth near the
/// bottom of the screen, fleeing a nearby touch, and being picked up /
/// dropped by dragging. `position` is the sprite's center point in the
/// same coordinate space as the hosting `GeometryReader`.
final class PotatoViewModel: ObservableObject {
    private enum State: Equatable {
        case idle
        case walking
        case fleeing
        case dragging
        case falling
    }

    @Published var position: CGPoint = .zero
    @Published var facingRight = true
    @Published var expression: PotatoSprite.Expression = .normal
    @Published var legPose: PotatoSprite.LegPose = .standing

    /// Updated by a full-screen background drag gesture; nil when no touch
    /// is down. Used to detect a nearby "poke" that should scare the potato.
    var currentTouch: CGPoint?

    private var state: State = .idle
    private var ticksInState = 0
    private var stateTarget = 18
    private var legToggle = false

    private var blinkCountdown = Int.random(in: 30...90)
    private var isBlinking = false

    private var fallVelocity: CGFloat = 0
    private var bounds: CGRect = .zero

    private var timer: AnyCancellable?

    private let groundInset: CGFloat = 48
    private let walkSpeed: CGFloat = 2
    private let fleeSpeed: CGFloat = 6
    private let fleeRadius: CGFloat = 90
    private let gravity: CGFloat = 1.6
    private let tickInterval: TimeInterval = 1.0 / 12.0

    private var halfWidth: CGFloat { PotatoSprite.pixelSize.width / 2 }
    private var groundY: CGFloat { bounds.maxY - groundInset }

    func start(in bounds: CGRect) {
        self.bounds = bounds
        position = CGPoint(x: bounds.midX, y: groundY)
        timer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func updateBounds(_ bounds: CGRect) {
        self.bounds = bounds
    }

    // MARK: - Dragging (called from the potato's own drag gesture)

    func beginDrag() {
        state = .dragging
        fallVelocity = 0
    }

    func drag(to point: CGPoint) {
        position = point
    }

    func endDrag() {
        if position.y < groundY - 1 {
            state = .falling
            fallVelocity = 0
        } else {
            position.y = groundY
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

        legPose = currentLegPose()
        expression = currentExpression()
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
        fallVelocity += gravity
        var newY = position.y + fallVelocity
        if newY >= groundY {
            newY = groundY
            fallVelocity = 0
            state = .idle
            ticksInState = 0
        }
        position.y = newY
    }

    private func tickAutonomous() {
        if tryFlee() { return }

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
            step(speed: walkSpeed)
            if ticksInState > stateTarget {
                state = .idle
                ticksInState = 0
                stateTarget = Int.random(in: 18...54)
            }
        default:
            break
        }
    }

    /// Switches to fleeing and moves away from a nearby touch. Returns true
    /// if fleeing handled this tick.
    private func tryFlee() -> Bool {
        guard let touch = currentTouch else {
            resumeFromFleeIfNeeded()
            return false
        }

        let dx = touch.x - position.x
        let dy = touch.y - position.y
        let distance = (dx * dx + dy * dy).squareRoot()

        guard distance < fleeRadius else {
            resumeFromFleeIfNeeded()
            return false
        }

        state = .fleeing
        facingRight = dx < 0
        legToggle.toggle()
        step(speed: fleeSpeed)
        return true
    }

    private func resumeFromFleeIfNeeded() {
        guard state == .fleeing else { return }
        state = .idle
        ticksInState = 0
        stateTarget = Int.random(in: 12...30)
    }

    private func step(speed: CGFloat) {
        var newX = position.x + (facingRight ? speed : -speed)
        let minX = bounds.minX + halfWidth
        let maxX = bounds.maxX - halfWidth

        if newX < minX {
            newX = minX
            facingRight = true
        } else if newX > maxX {
            newX = maxX
            facingRight = false
        }
        position = CGPoint(x: newX, y: groundY)
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
        case .dragging, .falling:
            return .surprised
        case .fleeing:
            return .scared
        case .idle, .walking:
            return isBlinking ? .blink : .normal
        }
    }
}

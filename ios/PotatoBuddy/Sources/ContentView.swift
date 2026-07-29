import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PotatoViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .gesture(backgroundTouchGesture)

                PotatoView(
                    expression: viewModel.expression,
                    legPose: viewModel.legPose,
                    facingRight: viewModel.facingRight
                )
                .position(viewModel.position)
                .gesture(potatoDragGesture)
            }
            .onAppear {
                viewModel.start(in: geo.frame(in: .local))
            }
            .onChange(of: geo.size) { _ in
                viewModel.updateBounds(geo.frame(in: .local))
            }
        }
    }

    /// Tracks touches on the background (not on the potato itself) so the
    /// view model can decide whether the potato should flee.
    private var backgroundTouchGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                viewModel.currentTouch = value.location
            }
            .onEnded { _ in
                viewModel.currentTouch = nil
            }
    }

    /// Lets the potato be picked up and dropped.
    private var potatoDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.beginDrag()
                viewModel.drag(to: value.location)
            }
            .onEnded { _ in
                viewModel.endDrag()
            }
    }
}

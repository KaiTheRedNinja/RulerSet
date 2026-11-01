import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    @Namespace var namespace

    var body: some View {
        NavigationStack {
            homePage
                .navigationDestination(for: Page.self) { page in
                    switch page {
                    case .ruler:
                        RulerView().navigationTransition(ZoomNavigationTransition.zoom(sourceID: "ruler", in: namespace))
                    case .protractor:
                        ProtractorView().navigationTransition(ZoomNavigationTransition.zoom(sourceID: "protractor", in: namespace))
                    case .level:
                        LevelView().navigationTransition(ZoomNavigationTransition.zoom(sourceID: "level", in: namespace))
                    case .tape:
                        TapeMeasureView().navigationTransition(ZoomNavigationTransition.zoom(sourceID: "tape", in: namespace))
                    }
                }
        }
        .environment(\.screenConversions, .device!)
    }

    enum Page {
        case ruler
        case protractor
        case level
        case tape
    }

    var homePage: some View {
        ZStack {
            Color.white.opacity(0.01) // fill the available space

            NavigationLink(value: Page.ruler) {
                RulerView(allowInteraction: false)
                    .matchedTransitionSource(id: "ruler", in: namespace)
            }
            .scaleEffect(0.6, anchor: .topLeading)

            NavigationLink(value: Page.protractor) {
                ProtractorView() // protractor has no interaction
                    .matchedTransitionSource(id: "protractor", in: namespace)
            }
            .rotationEffect(.degrees(180))
            .scaleEffect(0.6, anchor: .bottomTrailing)
            .padding(.bottom, 80)

            NavigationLink(value: Page.level) {
                LevelView(allowInteraction: false)
                    .matchedTransitionSource(id: "level", in: namespace)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .scaleEffect(0.6, anchor: .bottomLeading)

            NavigationLink(value: Page.tape) {
                TapeMeasureView(allowInteraction: false, bodyHiddenCm: 0)
                    .matchedTransitionSource(id: "tape", in: namespace)
            }
            .rotationEffect(.degrees(30))
            .scaleEffect(0.6, anchor: .topTrailing)
            .padding(.trailing, 50)
        }
        .clipped()
        .padding(30)
    }
}

struct SampleRectangleView: View {
    @Environment(\.screenConversions) var screen

    var body: some View {
        Rectangle()
            .frame(width: 1.0 * screen.pointsPerCentimeter, height: 3.0 * screen.pointsPerCentimeter)
            .onAppear {
                print("PPC: \(screen.pointsPerCentimeter)")
            }
    }
}

extension View {
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        clearance: CGFloat = 0,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self
            .padding(clearance)
            .mask {
                Rectangle()
                    .overlay(alignment: alignment) {
                        mask()
                            .padding(clearance)
                            .blendMode(.destinationOut)
                    }
            }
            .padding(-clearance)
    }
}

#Preview {
    ContentView()
}

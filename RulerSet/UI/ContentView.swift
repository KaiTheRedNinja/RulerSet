import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    @Namespace var namespace

    @State var openPage: Page?

    var body: some View {
        NavigationStack {
            switch openPage {
            case nil:
                homePage
            case .ruler:
                RulerView().matchedGeometryEffect(id: "ruler", in: namespace).toolbar { backButton }
            case .protractor:
                ProtractorView().matchedGeometryEffect(id: "protractor", in: namespace).toolbar { backButton }
            case .level:
                LevelView().matchedGeometryEffect(id: "level", in: namespace).toolbar { backButton }
            case .tape:
                TapeMeasureView().matchedGeometryEffect(id: "tape", in: namespace).toolbar { backButton }
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

            Button { withAnimation(.easeInOut) { openPage = Page.ruler } } label: {
                RulerView(allowInteraction: false)
                    .matchedGeometryEffect(id: "ruler", in: namespace)
            }
            .scaleEffect(0.6, anchor: .topLeading)

            Button { withAnimation(.easeInOut) { openPage = Page.protractor } } label: {
                ProtractorView() // protractor has no interaction
                    .matchedGeometryEffect(id: "protractor", in: namespace)
            }
            .scaleEffect(x: -1)
            .scaleEffect(0.6, anchor: .bottomTrailing)
            .padding(.bottom, 80)

            Button { withAnimation(.easeInOut) { openPage = Page.level } } label: {
                LevelView(allowInteraction: false)
                    .matchedGeometryEffect(id: "level", in: namespace)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .scaleEffect(0.6, anchor: .bottomLeading)

            Button { withAnimation(.easeInOut) { openPage = Page.tape } } label: {
                TapeMeasureView(allowInteraction: false, bodyHiddenCm: 0)
                    .matchedGeometryEffect(id: "tape", in: namespace)
            }
            .rotationEffect(.degrees(30))
            .scaleEffect(0.6, anchor: .topTrailing)
            .padding(.trailing, 50)
        }
        .clipped()
        .padding(30)
    }

    var backButton: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                withAnimation {
                    openPage = nil
                }
            } label: {
                Image(systemName: "chevron.left")
            }
        }
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

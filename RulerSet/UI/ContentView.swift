import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    let pointsPerCm = UIScreen.pointsPerCentimeter ?? 200

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Ruler", value: Page.ruler)
                NavigationLink("Protractor", value: Page.protractor)
                NavigationLink("Level", value: Page.level)
                NavigationLink("Tape", value: Page.tape)
            }
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .ruler: RulerView()
                case .protractor: ProtractorView()
                case .level: LevelView()
                case .tape: TapeMeasureView()
                }
            }
        }
        .environment(\.screenConversions, .device ?? .zero)
    }

    enum Page {
        case ruler
        case protractor
        case level
        case tape
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

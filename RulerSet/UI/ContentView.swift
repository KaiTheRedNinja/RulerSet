import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    @Namespace var namespace

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        .red,
                        .orange,
                        .yellow,
                        .green,
                        .cyan, // try not to use blue as rulers are blue
                        .purple,
                        .pink
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .saturation(0.8)
                .brightness(0.6)
                .ignoresSafeArea(.all)

                WavySections(
                    wavelength: 40,
                    amplitude: 5,
                    waveSpacing: 10,
                    phaseSpacing: 0.1
                )
                .fill(Color.white.opacity(0.2))
                .ignoresSafeArea(.all)

                homePage
                    .padding(30)
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
                    .foregroundStyle(Color.primary)
                    .matchedTransitionSource(id: "ruler", in: namespace)
            }
            .scaleEffect(0.6, anchor: .topLeading)

            NavigationLink(value: Page.protractor) {
                ProtractorView() // protractor has no interaction
                    .foregroundStyle(Color.primary)
                    .matchedTransitionSource(id: "protractor", in: namespace)
                    .clipped()
            }
            .rotationEffect(.degrees(180))
            .scaleEffect(0.6, anchor: .bottomTrailing)
            .padding(.bottom, 80)

            NavigationLink(value: Page.level) {
                LevelView(allowInteraction: false)
                    .foregroundStyle(Color.primary)
                    .matchedTransitionSource(id: "level", in: namespace)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .scaleEffect(0.6, anchor: .bottomLeading)

            NavigationLink(value: Page.tape) {
                TapeMeasureView(allowInteraction: false, bodyHiddenCm: 0)
                    .foregroundStyle(Color.primary)
                    .matchedTransitionSource(id: "tape", in: namespace)
            }
            .rotationEffect(.degrees(30))
            .scaleEffect(0.6, anchor: .topTrailing)
            .padding(.trailing, 50)
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

struct WavySections: Shape {
    // the distance between peaks of the same wave, in points
    var wavelength: CGFloat
    // the amplitude of a wave, in points
    var amplitude: CGFloat
    // the distance between the center line of consecutive waves, in points
    var waveSpacing: CGFloat
    // the phase difference between consecutive waves, in radians
    var phaseSpacing: CGFloat

    // Whether to rotate from vertical (false) to horizontal (true)
    var rotateAxis: Bool = false

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // account for rotation
        let width = rotateAxis ? rect.height : rect.width
        let height = rotateAxis ? rect.width : rect.height
        func point(x: CGFloat, y: CGFloat) -> CGPoint {
            if rotateAxis {
                .init(x: y, y: x)
            } else {
                .init(x: x, y: y)
            }
        }

        let waveCount = Int(width / waveSpacing)

        let sampleCount = Int(height) // one sample per y level
        let sampleHeight = CGFloat(1.0) // one point per sample

        for waveIndex in stride(from: 0, through: waveCount, by: 2) {
            let centerLineX1 = waveSpacing * CGFloat(waveIndex)
            let phase1 = phaseSpacing * CGFloat(waveIndex)
            path.move(to: point(x: centerLineX1, y: 0))

            for sampleIndex in 0..<sampleCount {
                let yPosition = sampleHeight * CGFloat(sampleIndex)
                let xPosition = centerLineX1 + amplitude * sin(yPosition / wavelength * (2 * .pi) + phase1)
                path.addLine(to: point(x: xPosition, y: yPosition))
            }

            let centerLineX2 = waveSpacing * CGFloat(waveIndex+1)
            let phase2 = phaseSpacing * CGFloat(waveIndex+1)
            for sampleIndex in (0..<sampleCount).reversed() {
                let yPosition = sampleHeight * CGFloat(sampleIndex)
                let xPosition = centerLineX2 + amplitude * sin(yPosition / wavelength * (2 * .pi) + phase2)
                path.addLine(to: point(x: xPosition, y: yPosition))
            }
            path.closeSubpath()
        }

        return path
    }
}

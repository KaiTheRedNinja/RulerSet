import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    let pointsPerCm = UIScreen.pointsPerCentimeter ?? 200

    var body: some View {
        SampleRectangleView()
            .environment(\.screenConversions, .device ?? .zero)
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

struct UIScreenConversion {
    var pixelsPerInch: CGFloat
    var pixelsPerCentimeter: CGFloat
    var pointsPerInch: CGFloat
    var pointsPerCentimeter: CGFloat
    var screenBoundPoints: CGRect

    static let zero: UIScreenConversion = .init(
        pixelsPerInch: 0,
        pixelsPerCentimeter: 0,
        pointsPerInch: 0,
        pointsPerCentimeter: 0,
        screenBoundPoints: .zero
    )

    static let device: UIScreenConversion? = {
        guard let pixelsPerInch = UIScreen.pixelsPerInch,
              let pixelsPerCentimeter = UIScreen.pixelsPerCentimeter,
              let pointsPerInch = UIScreen.pointsPerInch,
              let pointsPerCentimeter = UIScreen.pointsPerCentimeter,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return nil }

        return .init(
            pixelsPerInch: pixelsPerInch,
            pixelsPerCentimeter: pixelsPerCentimeter,
            pointsPerInch: pointsPerInch,
            pointsPerCentimeter: pointsPerCentimeter,
            screenBoundPoints: scene.screen.bounds
        )
    }()
}

extension EnvironmentValues {
    @Entry var screenConversions: UIScreenConversion = .zero
}

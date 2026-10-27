import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    let pointsPerCm = UIScreen.pointsPerCentimeter ?? 200

    var body: some View {
        RulerView()
//        GyroTestView()
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


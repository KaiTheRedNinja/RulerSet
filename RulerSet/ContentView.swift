import SwiftUI
import Playgrounds
import UIScreenExtension
import UIKit

struct ContentView: View {
    let pointsPerCm = UIScreen.pointsPerCentimeter ?? 200

    var body: some View {
        Rectangle()
            .frame(width: 1.0 * pointsPerCm, height: 3.0 * pointsPerCm)
            .onAppear {
                print("PPC: \(pointsPerCm)")
            }
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}

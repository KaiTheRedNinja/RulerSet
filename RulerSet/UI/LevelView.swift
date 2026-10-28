//
//  LevelView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 28/10/26.
//

import SwiftUI
import CoreMotion

struct LevelView: View {
    @State var manager: RotationManager = .init()

    // pitch is along the phone's x (width-wise) axis
    // roll is along the phone's y (length-wise) axis
    // yaw is along the world's vertical axis (perpendicular to the ground) and is not relevant here

    var body: some View {
        VStack {
            if let motion = manager.currentMotion {
                LevelIndicatorView(degrees: motion.attitude.roll * 180 / .pi)

                Spacer()
                    .frame(height: 50)

                LevelIndicatorView(degrees: motion.attitude.pitch * 180 / .pi)
                    .frame(height: 180 * 2)
                    .rotationEffect(.degrees(90))
            } else {
                Text("starting up...")
            }
        }
        .onAppear {
            manager.startDeviceMotion(frequency: 60.0) // we dont need 120Hz, 60Hz will do.
        }
        .onDisappear {
            manager.stopDeviceMotion()
        }
    }
}

struct LevelIndicatorView: View {
    var degrees: CGFloat

    var body: some View {
        let degAdj: CGFloat = (degrees + 360).truncatingRemainder(dividingBy: 360) // degrees but made positive
        let radius: CGFloat = 180
        let thickness: CGFloat = 80

        ZStack {
            Ellipse()
                .fill(Color.gray.opacity(0.5))
                .padding(.bottom, -50)
                .padding(.vertical, 20)
                .frame(width: radius * 2, height: thickness)
                .blur(radius: 10)

            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.45), Color(white: 0.8), Color(white: 0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: radius*2, height: thickness)

                ForEach(0..<36) { indicator in // ignore 360 degrees, because thats 0
                    let rotation = (CGFloat(indicator) * 10 - degAdj + 360.0).truncatingRemainder(dividingBy: 360)
                    if rotation < 90.0 || rotation > 270.0 {
                        VStack {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1, height: 10)
                                .offset(x: radius * sin(rotation * .pi / 180))

                            Spacer()

                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1, height: 10)
                                .offset(x: radius * sin(rotation * .pi / 180))
                        }

                        Text("\(indicator * 10)")
                            .monospaced()
                            .rotationEffect(.degrees(90))
                            .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0), anchorZ: -radius, perspective: 0.0001)
                    }
                }
            }
            .frame(height: thickness)

            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .stroke(Color.blue, lineWidth: 3)
                .overlay {
                    Text(String(format: "%03.1f", degAdj))
                        .frame(width: 100)
                        .rotationEffect(.degrees(90))
                        .monospaced()
                }
                .frame(width: thickness * 1/1.6, height: thickness)
        }
    }
}

#Preview {
    @Previewable @State var degrees: CGFloat = 0

    VStack {
        LevelIndicatorView(degrees: degrees)

        Slider(value: $degrees, in: -180...180)
    }
}

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

    // pitch is along the phone's y (length-wise) axis
    // roll is along the phone's x (width-wise) axis
    // yaw is along the world's vertical axis (perpendicular to the ground) and is not relevant here

    var body: some View {
        VStack {
            if let motion = manager.currentMotion {
                Text(
                    """
                    rotation:
                    - pitch : \(String(format: "% 08.5f", motion.attitude.pitch))
                    - roll  : \(String(format: "% 08.5f", motion.attitude.roll))
                    - yaw   : \(String(format: "% 08.5f", motion.attitude.yaw))
                    """
                )
                .monospaced()
            } else {
                Text("starting up...")
            }
        }
        .onAppear {
            manager.startDeviceMotion()
        }
        .onDisappear {
            manager.stopDeviceMotion()
        }
    }
}

struct LevelIndicatorView: View {
    var degrees: CGFloat

    var body: some View {
        EmptyView()
    }
}

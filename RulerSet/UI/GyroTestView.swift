//
//  GyroTestView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 26/10/26.
//

import SwiftUI
import CoreMotion

struct GyroTestView: View {
    @State var manager: GyroTestManager = .init()

    var body: some View {
        VStack {
            if let motion = manager.currentMotion {
                Text(
                    """
                    acceleration:
                    - x: \(String(format: "% 08.5f", motion.userAcceleration.x))
                    - y: \(String(format: "% 08.5f", motion.userAcceleration.y))
                    - z: \(String(format: "% 08.5f", motion.userAcceleration.z))
                    rotation rate:
                    - x: \(String(format: "% 08.5f", motion.rotationRate.x))
                    - y: \(String(format: "% 08.5f", motion.rotationRate.y))
                    - z: \(String(format: "% 08.5f", motion.rotationRate.z))
                    """
                )
                .monospaced()

                Text(
                    """
                    velocity:
                    - x: \(String(format: "% 08.5f", manager.currentVelocity.x))
                    - y: \(String(format: "% 08.5f", manager.currentVelocity.y))
                    - z: \(String(format: "% 08.5f", manager.currentVelocity.z))
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

@Observable
class GyroTestManager {
    @ObservationIgnored
    lazy var motion: CMMotionManager = .init()

    var motionTracking: Bool = false
    var zeroing: Bool = false
    var currentMotion: CMDeviceMotion?

    @ObservationIgnored
    var zeroingSamples: [Vec3D] = []
    @ObservationIgnored
    var accelerationOffset: Vec3D = .zero

    var currentAcceleration: Vec3D = .zero
    var currentVelocity: Vec3D = .zero
    var currentDisplacement: Vec3D = .zero

    @ObservationIgnored
    var lastObservationDate: Date = .distantPast

    func startDeviceMotion() {
        guard motion.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }

        motion.deviceMotionUpdateInterval = 1.0 / 120.0 // attempt to get 120Hz updates
        motion.showsDeviceMovementDisplay = true

        zeroing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.zeroing = false
        }

        lastObservationDate = .now
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] update, error in
            guard let self else { return }
            if let error {
                print("Error: \(error)")
                return
            }
            guard let update = update else {
                print("No motion provided")
                return
            }
            let now = Date.now
            let dt = now.timeIntervalSince(lastObservationDate)
            defer { lastObservationDate = now }

            let acceleration = Vec3D(
                x: update.userAcceleration.x,
                y: update.userAcceleration.y,
                z: update.userAcceleration.z
            ) * 9.81 // 1 G = 9.81 m/s2

            if zeroing {
                zeroingSamples.append(acceleration)
                // do not count until zeroing complete
                return
            } else if accelerationOffset == .zero {
                accelerationOffset = zeroingSamples.reduce(.zero, +) / CGFloat(zeroingSamples.count)
            }

            zeroingSamples.append(acceleration)

            self.currentMotion = update
            self.currentAcceleration = acceleration - accelerationOffset
            self.currentVelocity = currentVelocity + currentAcceleration * dt
            self.currentDisplacement = currentDisplacement + currentVelocity * dt
        }
    }

    func printSamples() {
        for (index, sample) in zeroingSamples.enumerated() {
            print(
                [CGFloat(index), sample.x, sample.y, sample.z]
                    .map { String(format: "% 08.5f", $0) }
                    .joined(separator: ",")
            )
        }
    }

    func stopDeviceMotion() {
        motion.stopDeviceMotionUpdates()
    }

    deinit {
        stopDeviceMotion()
    }
}

struct Vec3D: Hashable {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat

    static let zero = Vec3D(x: 0, y: 0, z: 0)

    nonisolated static func * (lhs: Vec3D, rhs: CGFloat) -> Vec3D {
        .init(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }

    nonisolated static func / (lhs: Vec3D, rhs: CGFloat) -> Vec3D {
        .init(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }

    nonisolated static func + (lhs: Vec3D, rhs: Vec3D) -> Vec3D {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    nonisolated static func - (lhs: Vec3D, rhs: Vec3D) -> Vec3D {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
}

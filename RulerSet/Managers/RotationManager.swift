//
//  RotationManager.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 28/10/26.
//

import SwiftUI
import CoreMotion

@Observable
class RotationManager {
    @ObservationIgnored
    lazy var motion: CMMotionManager = .init()

    var motionTracking: Bool = false
    var currentMotion: CMDeviceMotion?
    var referenceAttitude: CMAttitude?

    var processedAttitude: ProcessedAttitude? {
        guard let pitch = currentMotion?.attitude.pitch,
              let roll = currentMotion?.attitude.roll,
              let yaw = currentMotion?.attitude.yaw
        else { return nil }

        return .init(
            pitch: pitch - (referenceAttitude?.pitch ?? 0),
            roll: roll - (referenceAttitude?.roll ?? 0),
            yaw: yaw - (referenceAttitude?.yaw ?? 0)
        )
    }

    func startDeviceMotion(frequency: CGFloat = 120.0) {
        guard motion.isDeviceMotionAvailable else {
            print("Device motion not available")
            return
        }

        motion.deviceMotionUpdateInterval = 1.0 / frequency // attempt to get 120Hz updates
        motion.showsDeviceMovementDisplay = true

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

            self.currentMotion = update
        }
    }

    func tare() {
        referenceAttitude = currentMotion?.attitude
    }

    func stopDeviceMotion() {
        motion.stopDeviceMotionUpdates()
    }

    deinit {
        stopDeviceMotion()
    }
}

struct ProcessedAttitude {
    var pitch: CGFloat
    var roll: CGFloat
    var yaw: CGFloat
}

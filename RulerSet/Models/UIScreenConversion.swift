//
//  UIScreenConversion.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 26/10/26.
//

import UIScreenExtension
import UIKit
import SwiftUI

struct UIScreenConversion {
    var pixelsPerInch: CGFloat
    var pixelsPerCentimeter: CGFloat
    var pointsPerInch: CGFloat
    var pointsPerCentimeter: CGFloat
    var screenSizePoints: CGSize

    var screenSizeCm: CGSize {
        .init(
            width: screenSizePoints.width / pointsPerCentimeter,
            height: screenSizePoints.height / pointsPerCentimeter
        )
    }

    static let zero: UIScreenConversion = .init(
        pixelsPerInch: 0,
        pixelsPerCentimeter: 0,
        pointsPerInch: 0,
        pointsPerCentimeter: 0,
        screenSizePoints: .zero
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
            screenSizePoints: scene.screen.bounds.size
        )
    }()
}

extension EnvironmentValues {
    @Entry var screenConversions: UIScreenConversion = .zero
}

extension View {
    func frameCm(
        screen: UIScreenConversion,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> some View {
        self.frame(
            width: (width != nil) ? (width! * screen.pointsPerCentimeter) : nil,
            height: (height != nil) ? (height! * screen.pointsPerCentimeter) : nil,
            alignment: alignment
        )
    }

    func offsetCm(
        screen: UIScreenConversion,
        x: CGFloat = 0,
        y: CGFloat = 0,
    ) -> some View {
        self.offset(
            x: x * screen.pointsPerCentimeter,
            y: y * screen.pointsPerCentimeter
        )
    }
}

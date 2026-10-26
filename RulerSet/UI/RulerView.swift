//
//  RulerView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 26/10/26.
//

import SwiftUI

struct RulerView: View {
    @Environment(\.screenConversions) var screen

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white.opacity(0.01)
            let offsetPts = 0.5 * screen.pointsPerCentimeter

            Path { path in
                let mmLen = Int(screen.screenSizeCm.height) * 10
                // vertical ruler
                for mm in 0...mmLen {
                    let tickWidth: CGFloat = if mm == 0 { 0.5 } // zero is at 0.5 to allow for crossing
                    else if mm%10 == 0 { 0.8 }
                    else if mm%5 == 0 { 0.5 }
                    else { 0.3 }

                    path.move(to: .init(
                        x: 0,
                        y: offsetPts + CGFloat(mm) / 10 * screen.pointsPerCentimeter
                    ))
                    path.addLine(to: .init(
                        x: tickWidth * screen.pointsPerCentimeter,
                        y: offsetPts + CGFloat(mm) / 10 * screen.pointsPerCentimeter
                    ))
                    path.closeSubpath()
                }

                // horizontal ruler
                let mmWidth = Int(screen.screenSizeCm.width) * 10
                for mm in 0...mmWidth {
                    let tickWidth: CGFloat = if mm == 0 { 0.5 } // zero is at 0.5 to allow for crossing
                    else if mm%10 == 0 { 0.8 }
                    else if mm%5 == 0 { 0.5 }
                    else { 0.3 }

                    path.move(to: .init(
                        x: offsetPts + CGFloat(mm) / 10 * screen.pointsPerCentimeter,
                        y: 0
                    ))
                    path.addLine(to: .init(
                        x: offsetPts + CGFloat(mm) / 10 * screen.pointsPerCentimeter,
                        y: tickWidth * screen.pointsPerCentimeter
                    ))
                    path.closeSubpath()
                }
            }
            .stroke(Color.primary, lineWidth: 2)

            ForEach(0..<(Int(screen.screenSizeCm.height + 1)), id: \.self) { cm in
                Text("\(cm)")
                    .rotationEffect(.degrees(90))
                    .offsetCm(screen: screen, x: 0.6, y: 0.5 + CGFloat(cm))
            }

            ForEach(1..<(Int(screen.screenSizeCm.height + 1)), id: \.self) { cm in
                Text("\(cm)")
                    .rotationEffect(.degrees(180))
                    .offsetCm(screen: screen, x: 0.5 + 0.1 + CGFloat(cm), y: 0.4)
            }
        }
    }
}

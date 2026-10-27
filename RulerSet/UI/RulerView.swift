//
//  RulerView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 26/10/26.
//

import SwiftUI

struct RulerView: View {
    @Environment(\.screenConversions) var screen

    // TODO: consider making this app storage
    @State var topSide: Bool = true

    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .center) {
                rulers(sizePts: geom.size)
                    .rotationEffect(topSide ? .degrees(0) : .degrees(180))

                Button {
                    withAnimation {
                        topSide.toggle()
                    }
                } label: {
                    Image(systemName: topSide ? "rotate.right.fill" : "rotate.left.fill")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .ignoresSafeArea(edges: topSide ? [] : .bottom)
    }

    func rulers(sizePts: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            Color.white.opacity(0.01)
            let offsetPts = 0.5 * screen.pointsPerCentimeter

            let heightCm = Int(sizePts.height / screen.pointsPerCentimeter)
            let widthCm = Int(sizePts.width / screen.pointsPerCentimeter)

            // background
            Path { path in
                let totHeightPt = CGFloat(heightCm) * screen.pointsPerCentimeter + offsetPts
                let totWidthPt = CGFloat(widthCm) * screen.pointsPerCentimeter + offsetPts
                // draw a triangle around the shape
                path.move(to: .zero)
                path.addLine(to: .init(x: totWidthPt, y: 0))
                path.addLine(to: .init(x: totWidthPt, y: 1 * screen.pointsPerCentimeter))
                path.addLine(to: .init(x: 1 * screen.pointsPerCentimeter, y: totHeightPt))
                path.addLine(to: .init(x: 0, y: totHeightPt))
                path.addLine(to: .zero)
                path.closeSubpath()

                // draw a smaller inner triangle, offset in all directions by 1.5cm

                path.move(to: .init(x: 1.5 * screen.pointsPerCentimeter, y: 1.5 * screen.pointsPerCentimeter))
                path.addLine(to: .init(x: (CGFloat(widthCm) - 2.0) * screen.pointsPerCentimeter + offsetPts, y: 1.5 * screen.pointsPerCentimeter))
                path.addLine(
                    to: .init(
                        x: 1.5 * screen.pointsPerCentimeter,
                        y: (CGFloat(heightCm) - 2.0 * (totHeightPt / totWidthPt)) * screen.pointsPerCentimeter + offsetPts
                    )
                )
                path.addLine(to: .init(x: 1.5 * screen.pointsPerCentimeter, y: 1.5 * screen.pointsPerCentimeter))
                path.closeSubpath()
            }
            .fill(Color.red, style: .init(eoFill: true))

            // tickers
            Path { path in
                let mmLen = heightCm * 10
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
                let mmWidth = widthCm * 10
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

            // labels
            ForEach(0..<(heightCm + 1), id: \.self) { cm in
                Text("\(cm)")
                    .rotationEffect(.degrees(90))
                    .offsetCm(screen: screen, x: 0.6, y: 0.5 + CGFloat(cm))
                    .offsetCm(screen: screen, y: cm == heightCm ? -0.4 : 0)
            }

            ForEach(1..<(widthCm + 1), id: \.self) { cm in
                Text("\(cm)")
                    .rotationEffect(.degrees(180))
                    .offsetCm(screen: screen, x: 0.5 + 0.1 + CGFloat(cm), y: 0.4)
                    .offsetCm(screen: screen, x: cm == widthCm ? -0.4 : 0)
            }
        }
    }
}

#Preview {
    RulerView()
        .environment(\.screenConversions, .device ?? .zero)
}

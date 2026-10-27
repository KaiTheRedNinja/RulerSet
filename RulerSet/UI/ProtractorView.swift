//
//  ProtractorView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 27/10/26.
//

import SwiftUI

struct ProtractorView: View {
    @Environment(\.screenConversions) var screen

    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .center) {
                rulers(sizePts: geom.size)
            }
        }
    }

    func rulers(sizePts: CGSize) -> some View {
        ZStack(alignment: .leading) {
            Color.white.opacity(0.01)

            let radiusCm = min(
                Int(sizePts.height / screen.pointsPerCentimeter)/2,
                Int(sizePts.width / screen.pointsPerCentimeter)
            )

            // tickers
            Path { path in
                let radiusPts = CGFloat(radiusCm) * screen.pointsPerCentimeter

                let centerPoint = CGPoint(x: 0, y: sizePts.height/2)

                // TODO: redo these to look like protractors
                for degree in 0...180 {
                    let tickWidth: CGFloat = if degree == 0 { 0.5 } // zero is at 0.5 to allow for crossing
                    else if degree%10 == 0 { 0.8 }
                    else if degree%5 == 0 { 0.5 }
                    else { 0.3 }

                    let radian = CGFloat(degree) * (2 * .pi) / 180

                    let innerRadius = radiusPts - tickWidth * screen.pointsPerCentimeter

                    let endPoint = CGPoint(
                        x: centerPoint.x + radiusPts * sin(radian),
                        y: centerPoint.y + radiusPts * cos(radian)
                    )
                    let startPoint = CGPoint(
                        x: centerPoint.x + innerRadius * sin(radian),
                        y: centerPoint.y + innerRadius * cos(radian)
                    )

                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
            }
            .stroke(Color.primary, lineWidth: 2)

            // labels
//            ForEach(0..<(heightCm + 1), id: \.self) { cm in
//                Text("\(cm)")
//                    .rotationEffect(.degrees(90))
//                    .offsetCm(screen: screen, x: 0.6, y: 0.5 + CGFloat(cm))
//                    .offsetCm(screen: screen, y: cm == heightCm ? -0.4 : 0)
//            }
//
//            ForEach(1..<(widthCm + 1), id: \.self) { cm in
//                Text("\(cm)")
//                    .rotationEffect(.degrees(180))
//                    .offsetCm(screen: screen, x: 0.5 + 0.1 + CGFloat(cm), y: 0.4)
//                    .offsetCm(screen: screen, x: cm == widthCm ? -0.4 : 0)
//            }
        }
    }

//    func rulerBackground(sizePts: CGSize) -> some View {
//        let offsetPts = 0.5 * screen.pointsPerCentimeter
//
//        let heightCm = Int(sizePts.height / screen.pointsPerCentimeter)
//        let widthCm = Int(sizePts.width / screen.pointsPerCentimeter)
//
//        // background
//        let offsetWidth = CGFloat(widthCm) * screen.pointsPerCentimeter + offsetPts
//        let offsetHeight = CGFloat(heightCm) * screen.pointsPerCentimeter + offsetPts
//
//        let tickerSize = 0.8 * screen.pointsPerCentimeter
//        let extraWidth = ((tickerSize * offsetWidth) - (tickerSize * tickerSize))/(offsetHeight - tickerSize)
//        let extraHeight = ((tickerSize * offsetHeight) - (tickerSize * tickerSize))/(offsetWidth - tickerSize)
//
//        let totWidthPt = offsetWidth + extraWidth
//        let totHeightPt = offsetHeight + extraHeight
//
//        func drawInset(insetCm: CGFloat) -> Path {
//            var path = Path()
//            // draw a smaller inner triangle, offset in all directions by 1.5cm
//            let inset = insetCm * screen.pointsPerCentimeter
//            let scale = (totWidthPt - inset * 2.7) / totWidthPt
//            // note: we could do smth with trig, but i'm not bothered so we'll treat the diagonal inset as 1.7x the horizontal instead.
//
//            path.move(to: .init(x: inset, y: inset))
//            path.addLine(to: .init(x: inset + totWidthPt * scale, y: inset))
//            path.addLine(to: .init(x: inset, y: inset + totHeightPt * scale))
//            path.addLine(to: .init(x: inset, y: inset))
//            path.closeSubpath()
//
//            return path
//        }
//
//        return ZStack(alignment: .topLeading) {
//            drawInset(insetCm: 0)
//                .fill(Color.blue.opacity(0.3))
//            drawInset(insetCm: 0.5)
//                .fill(Color.blue.opacity(0.3))
//        }
//        .reverseMask(clearance: 30) {
//            drawInset(insetCm: 1.5)
//                .fill(Color.white)
//        }
//    }
}

#Preview {
    ProtractorView()
        .environment(\.screenConversions, .device ?? .zero)
}

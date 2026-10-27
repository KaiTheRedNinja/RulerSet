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
            rulerBackground(sizePts: sizePts)

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

    func rulerBackground(sizePts: CGSize) -> some View {
        let offsetPts = 0.5 * screen.pointsPerCentimeter

        let heightCm = Int(sizePts.height / screen.pointsPerCentimeter)
        let widthCm = Int(sizePts.width / screen.pointsPerCentimeter)

        // background
        let offsetWidth = CGFloat(widthCm) * screen.pointsPerCentimeter + offsetPts
        let offsetHeight = CGFloat(heightCm) * screen.pointsPerCentimeter + offsetPts

        let tickerSize = 0.8 * screen.pointsPerCentimeter
        let extraWidth = ((tickerSize * offsetWidth) - (tickerSize * tickerSize))/(offsetHeight - tickerSize)
        let extraHeight = ((tickerSize * offsetHeight) - (tickerSize * tickerSize))/(offsetWidth - tickerSize)

        let totWidthPt = offsetWidth + extraWidth
        let totHeightPt = offsetHeight + extraHeight

        func drawInset(insetCm: CGFloat) -> Path {
            var path = Path()
            // draw a smaller inner triangle, offset in all directions by 1.5cm
            let inset = insetCm * screen.pointsPerCentimeter
            let scale = (totWidthPt - inset * 2.7) / totWidthPt
            // note: we could do smth with trig, but i'm not bothered so we'll treat the diagonal inset as 1.7x the horizontal instead.

            path.move(to: .init(x: inset, y: inset))
            path.addLine(to: .init(x: inset + totWidthPt * scale, y: inset))
            path.addLine(to: .init(x: inset, y: inset + totHeightPt * scale))
            path.addLine(to: .init(x: inset, y: inset))
            path.closeSubpath()

            return path
        }

        return ZStack(alignment: .topLeading) {
            drawInset(insetCm: 0)
                .fill(Color.blue.opacity(0.3))
            drawInset(insetCm: 0.5)
                .fill(Color.blue.opacity(0.3))
        }
        .reverseMask(clearance: 30) {
            drawInset(insetCm: 1.5)
                .fill(Color.white)
        }
    }
}

#Preview {
    RulerView()
        .environment(\.screenConversions, .device ?? .zero)
}

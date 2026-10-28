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

            // the protractor is made of several radii, with lines in between:
            // radiusPts
            //    |
            // tickRadius (defined per-tick)
            //
            // labelRadius (where the ticks stop and labels start - no lines here really)
            //
            // decoratorRadius
            //    |
            // cutoffRadius OR innerTickRadius for non-5-divisible ticks
            let radiusPts = CGFloat(radiusCm) * screen.pointsPerCentimeter
            let decoratorRadius = radiusPts - 1.8 * screen.pointsPerCentimeter
            let labelRadius = radiusPts - 0.55 * screen.pointsPerCentimeter
            let innerTickRadius = decoratorRadius - 0.2 * screen.pointsPerCentimeter
            let cutoffRadius = 0.5 * screen.pointsPerCentimeter

            // background
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))

                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .padding(radiusPts - labelRadius)
            }
            .frame(width: radiusPts * 2, height: radiusPts * 2)
            .padding(.leading, -radiusPts)

            // tickers
            Path { path in
                let centerPoint = CGPoint(x: 0, y: sizePts.height/2)

                for degree in 0...180 {
                    let tickWidth: CGFloat = if degree%10 == 0 { 0.55 }
                    else if degree%5 == 0 { 0.45 }
                    else { 0.35 }

                    let radian = CGFloat(degree) * (.pi / 180)

                    let tickRadius = radiusPts - tickWidth * screen.pointsPerCentimeter

                    let startPoint1 = CGPoint(
                        x: centerPoint.x + radiusPts * sin(radian),
                        y: centerPoint.y + radiusPts * cos(radian)
                    )
                    let endPoint1 = CGPoint(
                        x: centerPoint.x + tickRadius * sin(radian),
                        y: centerPoint.y + tickRadius * cos(radian)
                    )

                    path.move(to: startPoint1)
                    path.addLine(to: endPoint1)

                    let startPoint2 = CGPoint(
                        x: centerPoint.x + decoratorRadius * sin(radian),
                        y: centerPoint.y + decoratorRadius * cos(radian)
                    )
                    let endPoint2 = CGPoint(
                        x: centerPoint.x + (degree%5 == 0 ? cutoffRadius : innerTickRadius) * sin(radian),
                        y: centerPoint.y + (degree%5 == 0 ? cutoffRadius : innerTickRadius) * cos(radian)
                    )

                    path.move(to: startPoint2)
                    path.addLine(to: endPoint2)
                }

                // separator arcs
                path.addArc(
                    center: centerPoint,
                    radius: radiusPts - 0.35 * screen.pointsPerCentimeter,
                    startAngle: .degrees(90),
                    endAngle: .degrees(-90),
                    clockwise: true
                )
                path.addArc(
                    center: centerPoint,
                    radius: decoratorRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(-90),
                    clockwise: true
                )
                path.addArc(
                    center: centerPoint,
                    radius: cutoffRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(-90),
                    clockwise: true
                )
                path.move(to: centerPoint)
                path.addLine(to: .init(x: centerPoint.x + cutoffRadius, y: centerPoint.y))
            }
            .stroke(Color.primary, lineWidth: 1)

            // labels
            ZStack(alignment: .leading) {
                ForEach(0..<(18+1)) { index in
                    let degree = CGFloat(index) * 10
                    VStack {
                        if index != 9 {
                            VStack {
                                Text("\(index * 10)") // note: this is an integer
                                Spacer()
                                Text("\(180 - index * 10)")
                            }
                            .padding(5)
                            .frame(height: labelRadius - decoratorRadius)
                        } else {
                            Text("90")
                                .font(.title)
                                .frame(height: labelRadius - decoratorRadius)
                        }
                        Spacer()
                    }
                    .frame(width: 50, height: 2*(radiusPts - 0.55 * screen.pointsPerCentimeter))
                    .rotationEffect(.degrees(degree), anchor: .center)
                    .padding(.leading, -25)
                }
            }
        }
    }
}

#Preview {
    ProtractorView()
        .environment(\.screenConversions, .device ?? .zero)
}

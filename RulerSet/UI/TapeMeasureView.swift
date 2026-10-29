//
//  TapeMeasureView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 29/10/26.
//

import SwiftUI

struct TapeMeasureView: View {
    @Environment(\.screenConversions) var screen

    let bodyLengthCm: CGFloat = 6.5
    let bodyWidthCm: CGFloat = 2.8
    let bodyHiddenCm: CGFloat = 4.0

    let tapeWidthCm: CGFloat = 1.8

    var body: some View {
        GeometryReader { geom in
            VStack(spacing: 0) {
                bodyView(size: geom.size)

                tapeView(size: geom.size)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .ignoresSafeArea(.all, edges: .vertical)
    }

    @ViewBuilder
    func bodyView(size: CGSize) -> some View {
        Rectangle()
            .fill(Color.gray)
            .frame(
                width: bodyWidthCm * screen.pointsPerCentimeter,
                height: bodyLengthCm * screen.pointsPerCentimeter
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.top, -bodyHiddenCm * screen.pointsPerCentimeter)
    }

    @ViewBuilder
    func tapeView(size: CGSize) -> some View {
        let tapeWidthPts: CGFloat = tapeWidthCm * screen.pointsPerCentimeter
        let tapeLengthPts: CGFloat = size.height
            - (bodyLengthCm - bodyHiddenCm) * screen.pointsPerCentimeter
        let tapeLengthCm: CGFloat = tapeLengthPts / screen.pointsPerCentimeter

        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.yellow)

            // tickers
            Path { path in
                // note: we start from the bottom
                // and also skip the first line bc thats not visible anyways
                for mmIndex in 1..<Int(tapeLengthCm * 10 + 1) {
                    let cm = CGFloat(mmIndex) / 10
                    let cmPts = cm * screen.pointsPerCentimeter

                    let tickWidth: CGFloat = if mmIndex%10 == 0 { 0.9 }
                    else if mmIndex%5 == 0 { 0.5 }
                    else { 0.3 }

                    path.move(
                        to: .init(
                            x: tapeWidthPts,
                            y: tapeLengthPts - cmPts
                        )
                    )
                    path.addLine(
                        to: .init(
                            x: (tapeWidthCm - tickWidth) * screen.pointsPerCentimeter,
                            y: tapeLengthPts - cmPts
                        )
                    )
                }
            }
            .stroke(Color.primary, lineWidth: 1)

            // numbers
            ForEach(1..<Int(tapeLengthCm+1), id: \.self) { index in
                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                    Text("\(index)")
                        .lineLimit(1)
                        .padding(.leading, 5)
                        .rotationEffect(.degrees(-90), anchor: .topLeading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.title3)
                .minimumScaleFactor(0.5)
                .monospaced()
                .frame(width: tapeWidthPts, height: 1 * screen.pointsPerCentimeter, alignment: .topTrailing)
                .offset(y: -CGFloat(index-1) * screen.pointsPerCentimeter)
            }

            // tab at the bottom
            Path { path in
                path.move(to: .init(x: 0, y: 60))
                path.addQuadCurve(
                    to: .init(x: 20, y: 60 - 15),
                    control: .init(x: 0, y: 60-15)
                )
                path.addQuadCurve(
                    to: .init(x: 40, y: 60 - 30),
                    control: .init(x: 40, y: 60-15)
                )

                path.addQuadCurve(
                    to: .init(x: tapeWidthPts - 40, y: 30),
                    control: .init(x: tapeWidthPts/2, y: 20)
                )

                path.addQuadCurve(
                    to: .init(x: tapeWidthPts - 20, y: 60 - 15),
                    control: .init(x: tapeWidthPts - 40, y: 60-15)
                )
                path.addQuadCurve(
                    to: .init(x: tapeWidthPts, y: 60),
                    control: .init(x: tapeWidthPts, y: 60-15)
                )

                path.closeSubpath()
            }
            .stroke(Color.black, lineWidth: 1)
            .fill(Color.gray)
            .reverseMask(alignment: .bottom) {
                Circle()
                    .frame(width: 15, height: 15)
                    .padding(.bottom, 10)
            }
            .overlay(alignment: .bottom) {
                Circle()
                    .fill(Color(white: 0.5))
                    .stroke(Color.black, lineWidth: 1)
                    .frame(width: 15, height: 15)
                    .padding(.bottom, 10)
            }
            .shadow(radius: 10)
            .frame(width: tapeWidthPts, height: 60)
        }
        .frame(
            width: tapeWidthPts,
            height: tapeLengthPts
        )
    }
}

#Preview {
    TapeMeasureView()
        .border(Color.red, width: 1)
        .padding(30)
        .environment(\.screenConversions, .device ?? .zero)
}

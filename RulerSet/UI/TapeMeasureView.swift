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

    @State var measuredLengthCm: CGFloat = 0

    @State var lastMeasuredLengthCm: CGFloat = 0

    var body: some View {
        GeometryReader { geom in
            VStack(spacing: 0) {
                bodyView(size: geom.size)
                tapeView(size: geom.size)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .ignoresSafeArea(.all, edges: .vertical)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let newLength = lastMeasuredLengthCm + value.translation.height / screen.pointsPerCentimeter
                    measuredLengthCm = overScroll(newLength)
                }
                .onEnded { value in
                    let newLength = lastMeasuredLengthCm + value.translation.height / screen.pointsPerCentimeter
                    measuredLengthCm = overScroll(newLength)
                    lastMeasuredLengthCm = measuredLengthCm

                    if newLength < 0 {
                        withAnimation(.bouncy(duration: 0.2, extraBounce: 0.2)) {
                            measuredLengthCm = 0
                            lastMeasuredLengthCm = 0
                        }
                    }
                }
        )
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

        let measuredPts: CGFloat = measuredLengthCm * screen.pointsPerCentimeter

        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.yellow)
                .padding(.bottom, -min(0, measuredPts))

            // tickers
            TapeTickers(
                tapeLengthPts: tapeLengthPts,
                tapeLengthCm: tapeLengthCm,
                tapeWidthPts: tapeWidthPts,
                tapeWidthCm: tapeWidthCm,
                measuredLengthCm: $measuredLengthCm
            )

            // numbers
            let startIndex = max(0, Int(measuredLengthCm-1))
            let endIndex = Int(tapeLengthCm+measuredLengthCm+1)
            ForEach(startIndex..<endIndex, id: \.self) { index in
                let yOffset = -CGFloat(index) * screen.pointsPerCentimeter + measuredPts

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
                .offset(y: yOffset + screen.pointsPerCentimeter)
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
            .offset(y: measuredPts)
        }
        .clipped()
        .frame(
            width: tapeWidthPts,
            height: tapeLengthPts
        )
    }
}

@Animatable
struct TapeTickers: View {
    @AnimatableIgnored
    @Environment(\.screenConversions) var screen

    var tapeLengthPts: CGFloat
    var tapeLengthCm: CGFloat
    var tapeWidthPts: CGFloat
    var tapeWidthCm: CGFloat
    @Binding var measuredLengthCm: CGFloat

    var body: some View {
        // tickers
        Path { path in
            // we only render the ones that are visible
            // those are from measuredLengthCm to measuredLengthCm + tapeLengthCm

            // note: we start from the bottom
            // and also skip the first line bc thats not visible anyways
            let startIndex = max(1, Int(measuredLengthCm * 10 + 1))
            let endIndex = Int((tapeLengthCm + measuredLengthCm) * 10 + 1)

            for mmIndex in startIndex..<endIndex {
                let cm = CGFloat(mmIndex) / 10 - measuredLengthCm

                // dont bother with rendering those out of view
                if cm <= 0 || cm > tapeLengthCm { continue }

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
    }
}

func overScroll(_ x: CGFloat) -> CGFloat {
    guard x < 0 else { return x }

    let resistance: CGFloat = 0.5
    let limit: CGFloat = 120

    return -limit * (1 - exp(x * resistance / limit))
}

#Preview {
    @Previewable @State var lengthOffsetPts: CGFloat = 0

    VStack {
        TapeMeasureView()
            .border(Color.red, width: 1)
            .padding(30)
            .environment(\.screenConversions, .device ?? .zero)
    }
}

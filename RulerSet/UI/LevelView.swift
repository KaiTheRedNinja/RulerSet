//
//  LevelView.swift
//  RulerSet
//
//  Created by Kai Quan Tay on 28/10/26.
//

import SwiftUI
import CoreMotion

struct LevelView: View {
    @State var manager: RotationManager = .init()

    // pitch is along the phone's x (width-wise) axis
    // roll is along the phone's y (length-wise) axis
    // yaw is along the world's vertical axis (perpendicular to the ground) and is not relevant here

    var body: some View {
        VStack {
            if let attitude = manager.processedAttitude {
                ZStack(alignment: .topLeading) {
                    LevelIndicatorView(degrees: -attitude.pitch * 180 / .pi)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 180 * 2)
                        .zIndex(2)
                        .padding(.leading, 20)

                    LevelIndicatorView(degrees: attitude.roll * 180 / .pi)
                        .zIndex(1)
                        .padding(.top, 20)

                    DiskIndicatorView(degrees: -attitude.yaw * 180 / .pi)
                        .zIndex(0)
                }
            } else {
                Text("starting up...")
            }
        }
        .onAppear {
            manager.startDeviceMotion(frequency: 60.0) // we dont need 120Hz, 60Hz will do.
        }
        .onDisappear {
            manager.stopDeviceMotion()
        }
        .toolbar {
            Button {
                // zero the measurements
                withAnimation {
                    manager.tare()
                }
            } label: {
                Image(systemName: "circle.and.line.horizontal.fill")
            }
            .contextMenu {
                Button {
                    // remove reference
                    withAnimation {
                        manager.referenceAttitude = nil
                    }
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }
}

struct LevelIndicatorView: View {
    var degrees: CGFloat

    // The width of the dial
    var visibleWidth: CGFloat = 350
    // The degrees visible on the dial. Do not set higher than 180.
    var visibleDegrees: CGFloat = 150

    var body: some View {
        let degAdj: CGFloat = (degrees + 360).truncatingRemainder(dividingBy: 360) // degrees but made positive
        let radius: CGFloat = visibleWidth / (2 * sin(visibleDegrees/2 * .pi / 180))
        let thickness: CGFloat = 80

        ZStack {
            Ellipse()
                .fill(Color.gray.opacity(0.5))
                .padding(.bottom, -50)
                .padding(.vertical, 20)
                .frame(width: radius * 2, height: thickness)
                .blur(radius: 10)

            let edgeRadius: CGFloat = 10

            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.45), Color(white: 0.8), Color(white: 0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    stops: [
                                        .init(color: Color(white: 0.35), location: 0),
                                        .init(color: Color(white: 0.4, opacity: 0.5), location: 0.2),
                                        .init(color: Color.clear, location: 0.4),
                                        .init(color: Color.clear, location: 0.6),
                                        .init(color: Color(white: 0.4, opacity: 0.5), location: 0.8),
                                        .init(color: Color(white: 0.35), location: 1),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(width: visibleWidth, height: thickness)

                Path { path in
                    for indicator in 0..<360 {
                        let rotation = (CGFloat(indicator) - degAdj + 360.0).truncatingRemainder(dividingBy: 360)
                        let rotRad = rotation * .pi / 180
                        // ignore if not visible
                        guard rotation < (visibleDegrees / 2) || rotation > 360 - (visibleDegrees/2) else { continue }

                        // draw the line
                        let tickerWidth: CGFloat = if indicator%10 == 0 { 20 }
                        else if indicator%5 == 0 { 10 }
                        else { 6 }

                        if tickerWidth == 6 {
                            path.move(to: .init(x: visibleWidth/2 + (radius - edgeRadius) * sin(rotRad), y: 0))
                            path.addQuadCurve(
                                to: .init(x: visibleWidth/2 + radius * sin(rotRad), y: tickerWidth),
                                control: .init(x: visibleWidth/2 + radius * sin(rotRad), y: 0)
                            )

                            path.move(to: .init(x: visibleWidth/2 + radius * sin(rotRad), y: thickness - tickerWidth))
                            path.addQuadCurve(
                                to: .init(x: visibleWidth/2 + (radius - edgeRadius) * sin(rotRad), y: thickness),
                                control: .init(x: visibleWidth/2 + radius * sin(rotRad), y: thickness)
                            )
                        } else {
                            path.move(to: .init(x: visibleWidth/2 + (radius - edgeRadius) * sin(rotRad), y: 0))
                            path.addQuadCurve(
                                to: .init(x: visibleWidth/2 + radius * sin(rotRad), y: edgeRadius),
                                control: .init(x: visibleWidth/2 + radius * sin(rotRad), y: 0)
                            )
                            path.addLine(to: .init(x: visibleWidth/2 + radius * sin(rotRad), y: tickerWidth))

                            path.move(to: .init(x: visibleWidth/2 + radius * sin(rotRad), y: thickness - tickerWidth))
                            path.addLine(to: .init(x: visibleWidth/2 + radius * sin(rotRad), y: thickness - edgeRadius))
                            path.addQuadCurve(
                                to: .init(x: visibleWidth/2 + (radius - edgeRadius) * sin(rotRad), y: thickness),
                                control: .init(x: visibleWidth/2 + radius * sin(rotRad), y: thickness)
                            )
                        }
                    }
                }
                .stroke(Color.black, lineWidth: 1)

                ForEach(0..<36) { indicator in // ignore 360 degrees, because thats 0
                    let rotation = (CGFloat(indicator) * 10 - degAdj + 360.0).truncatingRemainder(dividingBy: 360)
                    if rotation < (visibleDegrees / 2) || rotation > 360 - (visibleDegrees/2) {

                        Text("\(indicator * 10)")
                            .monospaced()
                            .rotationEffect(.degrees(90))
                            .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0), anchorZ: -radius, perspective: 0.0001)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: edgeRadius))
            .frame(width: visibleWidth, height: thickness)

            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
                .stroke(Color.primary, lineWidth: 1)
                .shadow(radius: 10)
                .reverseMask(clearance: 50) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: thickness * 1/1.6 - 20, height: thickness - 20)
                }
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.primary, lineWidth: 1)

                        // if it is aligned within the display
                        let isAligned = degAdj < 0.05 || degAdj > 359.95

                        Text(String(format: "%03.1f", degAdj))
                            .frame(width: 100)
                            .rotationEffect(.degrees(90))
                            .monospaced()
                            .frame(width: thickness * 1/1.6 - 20, height: thickness - 20)
                            .glassEffect(.clear.tint(isAligned ? Color.green : Color(white: 0.6)), in: .rect(cornerRadius: 5.0))
                    }
                    .frame(width: thickness * 1/1.6 - 20, height: thickness - 20)
                }
                .frame(width: thickness * 1/1.6, height: thickness + 20)
        }
    }
}

struct DiskIndicatorView: View {
    var degrees: CGFloat

    // The width of the disk
    var visibleWidth: CGFloat = 350

    var body: some View {
        ZStack {
            let degAdj: CGFloat = (degrees + 360).truncatingRemainder(dividingBy: 360) // degrees but made positive

            Circle()
                .fill(Color.gray.opacity(0.5))
                .padding(.bottom, -50)
                .padding(.vertical, 20)
                .frame(width: visibleWidth, height: visibleWidth)
                .blur(radius: 10)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(white: 0.8), Color(white: 0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: visibleWidth/2
                        )
                    )
                    .frame(width: visibleWidth, height: visibleWidth)

                let centerPoint = CGPoint(x: visibleWidth/2, y: visibleWidth/2)
                Path { path in
                    for indicator in 0..<360 {
                        let rotation = (CGFloat(indicator) - degAdj + 360.0).truncatingRemainder(dividingBy: 360)
                        let rotRad = rotation * .pi / 180

                        // draw the line
                        let tickerWidth: CGFloat = if indicator%10 == 0 { 20 }
                        else if indicator%5 == 0 { 10 }
                        else { 6 }

                        path.move(
                            to: .init(
                                x: centerPoint.x + visibleWidth/2 * cos(rotRad),
                                y: centerPoint.y + visibleWidth/2 * sin(rotRad)
                            )
                        )
                        path.addLine(
                            to: .init(
                                x: centerPoint.x + (visibleWidth/2 - tickerWidth) * cos(rotRad),
                                y: centerPoint.y + (visibleWidth/2 - tickerWidth) * sin(rotRad)
                            )
                        )

                        if indicator%10 == 0 {
                            path.move(
                                to: .init(
                                    x: centerPoint.x + (visibleWidth/2 - 60) * cos(rotRad),
                                    y: centerPoint.y + (visibleWidth/2 - 60) * sin(rotRad)
                                )
                            )
                            path.addLine(
                                to: .init(
                                    x: centerPoint.x + 30 * cos(rotRad),
                                    y: centerPoint.y + 30 * sin(rotRad)
                                )
                            )
                        }
                    }
                }
                .stroke(Color.black, lineWidth: 1)

                Path { path in
                    let sideCount: Int = 18
                    let outerRadius: CGFloat = 35
                    let innerRadius: CGFloat = 30

                    let segmentRad = 2 * CGFloat.pi / CGFloat(sideCount * 2)

                    path.move(
                        to: .init(
                            x: centerPoint.x + outerRadius,
                            y: centerPoint.y
                        )
                    )

                    for side in 0...(sideCount * 2) {
                        let radius = side%2 == 0 ? outerRadius : innerRadius
                        path.addLine(
                            to: .init(
                                x: centerPoint.x + radius * cos(CGFloat(side) * segmentRad),
                                y: centerPoint.y + radius * sin(CGFloat(side) * segmentRad)
                            )
                        )
                    }
                    path.closeSubpath()
                }
                .fill(
                    RadialGradient(
                        colors: [Color(white: 0.8), Color(white: 0.4)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    )
                )
                .stroke(Color.black, lineWidth: 1)

                ForEach(0..<36) { indicator in // ignore 360 degrees, because thats 0
                    let rotation = (CGFloat(indicator) * 10 - degAdj + 360.0).truncatingRemainder(dividingBy: 360)

                    HStack {
                        Spacer()
                        Text("\(indicator * 10)")
                            .monospaced()
                    }
                    .frame(width: visibleWidth - 50)
                    .rotationEffect(.degrees(rotation))
                }
            }
            .clipShape(Circle())
            .frame(width: visibleWidth, height: visibleWidth)

            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .stroke(Color.primary, lineWidth: 1)
                .shadow(radius: 10)
                .reverseMask(clearance: 50) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 30)
                }
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 1)

                        // if it is aligned within the display
                        let isAligned = degAdj < 0.05 || degAdj > 359.95

                        Text(String(format: "%03.1f", degAdj))
                            .monospaced()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(.clear.tint(isAligned ? Color.green : Color(white: 0.6)), in: .rect(cornerRadius: 5.0))
                    }
                    .frame(width: 60, height: 30)
                }
                .background(alignment: .leading) {
                    Path { path in
                        path.move(to: .init(x: 0, y: 18))
                        path.addLine(to: .init(x: -20, y: 25))
                        path.addLine(to: .init(x: 0, y: 32))
                        path.addLine(to: .init(x: 0, y: 18))
                        path.closeSubpath()
                    }
                    .fill(Color.red)
                    .stroke(Color.black, lineWidth: 1)
                }
                .padding(.trailing, -10)
                .frame(width: 90, height: 50)
                .frame(width: visibleWidth, alignment: .trailing)
        }
    }
}

#Preview {
    @Previewable @State var degrees: CGFloat = 0

    VStack {
        DiskIndicatorView(degrees: degrees)

        Slider(value: $degrees, in: -180...180)
    }
}

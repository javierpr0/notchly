import SwiftUI

struct BotFaceView: View {
    var state: NotchDisplayState = .idle

    @State private var eyeOffset: CGFloat = 0
    @State private var isBlinking = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let eyeW = w * 0.16
            let eyeH = h * 0.18
            let eyeY = h * 0.28
            let leftEyeX = w * 0.28
            let rightEyeX = w * 0.72

            let cheekW = w * 0.14
            let cheekH = h * 0.1
            let cheekY = h * 0.52

            let mouthW = w * 0.22
            let mouthH = h * 0.08

            let eyeColor: Color = .white
            let mouthColor: Color = .white
            let cheekColor = Color(red: 1.0, green: 0.45, blue: 0.55)

            Canvas { context, size in
                // Cheeks
                let leftCheek = CGRect(x: w * 0.06, y: cheekY, width: cheekW, height: cheekH)
                let rightCheek = CGRect(x: w * 0.80, y: cheekY, width: cheekW, height: cheekH)
                context.fill(Path(roundedRect: leftCheek, cornerRadius: cheekH * 0.3), with: .color(cheekColor.opacity(cheekOpacity)))
                context.fill(Path(roundedRect: rightCheek, cornerRadius: cheekH * 0.3), with: .color(cheekColor.opacity(cheekOpacity)))

                // Eyes
                let blinkH = isBlinking ? eyeH * 0.15 : eyeHeight(eyeH)
                let blinkYOffset = isBlinking ? eyeH * 0.4 : eyeYOffset(eyeH)
                let leftEye = CGRect(
                    x: leftEyeX - eyeW / 2 + eyeOffset,
                    y: eyeY + blinkYOffset,
                    width: eyeW,
                    height: blinkH
                )
                let rightEye = CGRect(
                    x: rightEyeX - eyeW / 2 + eyeOffset,
                    y: eyeY + blinkYOffset,
                    width: eyeW,
                    height: blinkH
                )

                if state == .taskCompleted && !isBlinking {
                    var leftArc = Path()
                    leftArc.addArc(
                        center: CGPoint(x: leftEye.midX, y: leftEye.maxY),
                        radius: eyeW * 0.6,
                        startAngle: .degrees(-160), endAngle: .degrees(-20), clockwise: false
                    )
                    context.stroke(leftArc, with: .color(eyeColor), style: StrokeStyle(lineWidth: eyeH * 0.35, lineCap: .round))

                    var rightArc = Path()
                    rightArc.addArc(
                        center: CGPoint(x: rightEye.midX, y: rightEye.maxY),
                        radius: eyeW * 0.6,
                        startAngle: .degrees(-160), endAngle: .degrees(-20), clockwise: false
                    )
                    context.stroke(rightArc, with: .color(eyeColor), style: StrokeStyle(lineWidth: eyeH * 0.35, lineCap: .round))
                } else {
                    context.fill(Path(roundedRect: leftEye, cornerRadius: eyeW * 0.2), with: .color(eyeColor))
                    context.fill(Path(roundedRect: rightEye, cornerRadius: eyeW * 0.2), with: .color(eyeColor))
                }

                // Mouth
                let mouthX = w * 0.5 - mouthW / 2
                let mouthY = h * 0.62
                if state == .taskCompleted {
                    var smile = Path()
                    smile.addArc(
                        center: CGPoint(x: w * 0.5, y: mouthY),
                        radius: mouthW * 0.45,
                        startAngle: .degrees(10), endAngle: .degrees(170), clockwise: false
                    )
                    context.stroke(smile, with: .color(mouthColor), style: StrokeStyle(lineWidth: mouthH * 0.7, lineCap: .round))
                } else if state == .waitingForInput {
                    let openMouth = CGRect(x: mouthX + mouthW * 0.15, y: mouthY, width: mouthW * 0.7, height: mouthH * 1.8)
                    context.fill(Path(roundedRect: openMouth, cornerRadius: mouthH * 0.4), with: .color(mouthColor))
                } else {
                    let mouth = CGRect(x: mouthX, y: mouthY, width: mouthW, height: mouthH)
                    context.fill(Path(roundedRect: mouth, cornerRadius: mouthH * 0.3), with: .color(mouthColor))
                }
            }
        }
        .onChange(of: state) {
            updateAnimations()
        }
        .onAppear {
            updateAnimations()
            startBlinkLoop()
        }
    }

    private var cheekOpacity: Double {
        state == .taskCompleted ? 1.0 : 0.7
    }

    private func eyeHeight(_ base: CGFloat) -> CGFloat {
        state == .waitingForInput ? base * 1.3 : base
    }

    private func eyeYOffset(_ base: CGFloat) -> CGFloat {
        state == .waitingForInput ? -base * 0.15 : 0
    }

    private func updateAnimations() {
        withAnimation(.easeInOut(duration: 0.2)) {
            eyeOffset = 0
        }

        if state == .working {
            startLookAround()
        }
    }

    private func startLookAround() {
        guard state == .working else { return }
        withAnimation(.easeInOut(duration: 0.6)) {
            eyeOffset = 2.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard self.state == .working else { return }
            withAnimation(.easeInOut(duration: 0.6)) {
                self.eyeOffset = -2.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            guard self.state == .working else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                self.eyeOffset = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            self.startLookAround()
        }
    }

    private func startBlinkLoop() {
        let delay = Double.random(in: 3.0...6.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.08)) {
                self.isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.08)) {
                    self.isBlinking = false
                }
            }
            self.startBlinkLoop()
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        VStack {
            BotFaceView(state: .idle)
                .frame(width: 40, height: 30)
            Text("Idle").font(.caption)
        }
        VStack {
            BotFaceView(state: .working)
                .frame(width: 40, height: 30)
            Text("Working").font(.caption)
        }
        VStack {
            BotFaceView(state: .waitingForInput)
                .frame(width: 40, height: 30)
            Text("Waiting").font(.caption)
        }
        VStack {
            BotFaceView(state: .taskCompleted)
                .frame(width: 40, height: 30)
            Text("Done").font(.caption)
        }
    }
    .padding()
    .background(Color.black)
    .foregroundColor(.white)
}

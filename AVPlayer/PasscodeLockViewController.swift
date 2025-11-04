// MARK: SwiftUI 기반 잠금스크린

import SwiftUI
import LocalAuthentication

struct PasscodeLockView: View {
    // MARK: - Public
    var onUnlock: (() -> Void)?

    // MARK: - Private State
    @State private var input: [Int] = []
    @State private var hasAttemptedAutoBiometrics = false
    @State private var canUseBiometrics: Bool = false
    @State private var useFaceIDByDefault: Bool = UserDefaults.standard.bool(forKey: "app.useFaceIDByDefault")
    @State private var randomizedKeypadRows: [[String]] = []
    private let passcodeLength = 6
    private let defaultsKey = "app.passcode"
    private let useFaceIDDefaultsKey = "app.useFaceIDByDefault"

    private var currentPasscode: String {
        let stored = UserDefaults.standard.string(forKey: defaultsKey)
        return (stored?.isEmpty == false) ? stored! : "100712"
    }

    private var dotFillColor: Color { .primary }
    private var dotEmptyColor: Color { .secondary.opacity(0.3) }
    private var shouldShowFaceID: Bool { canUseBiometrics }
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 6) {
                Text("잠금 해제")
                    .font(.system(size: 24, weight: .semibold))
                Text("비밀번호를 입력하세요")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
//                Button {
//                    authenticateWithBiometrics()
//                } label: {
//                    HStack(spacing: 8) {
//                        Image(systemName: "faceid")
//                        Text("Face ID로 잠금 해제")
//                    }
//                    .font(.system(size: 15, weight: .semibold))
//                }
//                .buttonStyle(.plain)
//                .opacity(shouldShowFaceID ? 1 : 0)
//                .accessibilityHidden(!shouldShowFaceID)
                HStack(spacing: 8) {
                    Button {
                        useFaceIDByDefault.toggle()
                        UserDefaults.standard.set(useFaceIDByDefault, forKey: useFaceIDDefaultsKey)
                    } label: {
                        Image(systemName: useFaceIDByDefault ? "checkmark.square.fill" : "square")
                            .foregroundStyle(.secondary)
                        Text("다음부터 Face ID 이용하기")
                    }
                    .buttonStyle(.plain)
                }
                .font(.system(size: 15))
                .opacity(shouldShowFaceID ? 1 : 0)
                .accessibilityHidden(!shouldShowFaceID)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                ForEach(0..<passcodeLength, id: \.self) { idx in
                    Circle()
                        .fill(idx < input.count ? dotFillColor : dotEmptyColor)
                        .frame(width: 20, height: 20)
                        .animation(.easeInOut(duration: 0.15), value: input)
                }
            }
            .accessibilityLabel("입력된 자리수 \(input.count)개")

            Spacer(minLength: 0)

            // Keypad
            keypad
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 24)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            updateBiometricAvailability()
            useFaceIDByDefault = UserDefaults.standard.bool(forKey: useFaceIDDefaultsKey)
            if randomizedKeypadRows.isEmpty {
                randomizedKeypadRows = buildRandomizedKeypadRows()
            }
        }
        .animation(.easeInOut(duration: 0.15), value: input)
        .task {
            await tryAutoAuthenticate()
        }
    }
    
    // MARK: - Keypad
    private var keypad: some View {
        VStack(spacing: 12) {
            ForEach(Array(randomizedKeypadRows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 12) {
                    ForEach(Array(row.enumerated()), id: \.offset) { colIndex, symbol in
                        if symbol.isEmpty {
                            Color.clear
                                .frame(height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                .accessibilityHidden(true)
                        } else if symbol == "faceid" {
                            if shouldShowFaceID {
                                Button {
                                    authenticateWithBiometrics()
                                } label: {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                        .frame(maxWidth: .infinity, minHeight: 64)
                                        .background(
                                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                                .fill(colorScheme == .dark ? Color.black : Color.white)
                                        )
                                }
                                .buttonStyle(PressScaleStyle())
                                .accessibilityLabel("Face ID")
                            } else {
                                Color.clear
                                    .frame(height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                    .accessibilityHidden(true)
                            }
                        } else {
                            Button {
                                if symbol == "←" {
                                    handleDelete()
                                } else {
                                    handleTap(symbol)
                                }
                            } label: {
                                Group {
                                    if symbol == "←" {
                                        Text("←")
                                    } else {
                                        Text(symbol)
                                    }
                                }
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(
                                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                                        .fill(colorScheme == .dark ? Color.black : Color.white)
                                )
                            }
                            .buttonStyle(PressScaleStyle())
                            .accessibilityLabel(symbol == "←" ? "지우기" : symbol)
                        }
                    }
                }
            }
        }
    }

    private func buildRandomizedKeypadRows() -> [[String]] {
        
        // 숫자 0-9 + faceid 총 11가지만 전부 무작위로 섞어서 4x3 그리드로 배치
        var mix: [String] = Array(0...9).map { String($0) }
        mix.append("faceid")
        mix.shuffle()
        
        if mix.count > 11 { mix = Array(mix.prefix(11)) }
        var keeps = mix
        keeps.append("←")

        var rows: [[String]] = []
        for i in 0..<4 {
            let start = i * 3
            let end = start + 3
            let row = Array(keeps[start..<end])
            rows.append(row)
        }
        return rows
        
        // 숫자 0-9 + faceid + 삭제(←) 총 12개를 전부 무작위로 섞어서 4x3 그리드로 배치
//        var mix: [String] = Array(0...9).map { String($0) }
//        mix.append("faceid")
//        mix.append("←")
//        mix.shuffle()
//
//        var rows: [[String]] = []
//        for i in 0..<4 {
//            let start = i * 3
//            let end = start + 3
//            let row = Array(mix[start..<end])
//            rows.append(row)
//        }
//        return rows

        // 숫자 0-9 총 10개만 전부 무작위로 섞어서 4x3 그리드로 배치 (faceid/삭제 제외)
//        var mix: [String] = Array(0...9).map { String($0) }
//        mix.shuffle()
//
//        // mix에 바로 빈칸 2개 추가해서 12칸 맞추기
//        mix.append("")
//        mix.append("")
//
//        var rows: [[String]] = []
//        for i in 0..<4 {
//            let start = i * 3
//            let end = start + 3
//            let row = Array(mix[start..<end])
//            rows.append(row)
//        }
//        return rows
    }

    // MARK: - Actions
    private func handleTap(_ symbol: String) {
        guard let number = Int(symbol), input.count < passcodeLength else { return }
        input.append(number)
        if input.count == passcodeLength {
            validate()
        }
    }
    
    private func handleDelete() {
        guard !input.isEmpty else { return }
        input.removeLast()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @MainActor
    private func authenticateWithBiometrics() {
        let context = LAContext()
        context.localizedCancelTitle = "취소"
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            let reason = "Face ID로 잠금을 해제합니다."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        onUnlock?()
                    } else {
                        if let _ = error { UINotificationFeedbackGenerator().notificationOccurred(.error) }
                    }
                }
            }
        }
    }

    @MainActor
    private func tryAutoAuthenticate() async {
        guard !hasAttemptedAutoBiometrics else { return }
        hasAttemptedAutoBiometrics = true
        updateBiometricAvailability()
        if canUseBiometrics && useFaceIDByDefault {
            authenticateWithBiometrics()
        }
    }

    private func validate() {
        let entered = input.map(String.init).joined()
        if entered == currentPasscode {
            // Success haptic
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            // Optional: 작은 페이드/스케일 아웃
            withAnimation(.easeInOut(duration: 0.25)) {
                // SwiftUI에서는 부모에서 dismiss하거나 onUnlock 호출
            }
            onUnlock?()
        } else {
            // Error haptic
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            // Shake animation on indicators (basic)
            withAnimation(.default) {
                // 간단히 리셋만: 필요시 커스텀 modifier로 shake 구현 가능
            }
            input.removeAll()
        }
    }

    private func updateBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}

// MARK: - Button Press Style (scale + background tweak)
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.black.opacity(configuration.isPressed ? 0.06 : 0.0))
                    )
            )
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

//#Preview {
//    PasscodeLockView(onUnlock: {
//        print("Unlocked!")
//    })
//    .preferredColorScheme(.light)
//}


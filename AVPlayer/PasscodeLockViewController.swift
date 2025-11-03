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
    private let passcodeLength = 4
    private let defaultsKey = "app.passcode"
    private let useFaceIDDefaultsKey = "app.useFaceIDByDefault"

    private var currentPasscode: String {
        let stored = UserDefaults.standard.string(forKey: defaultsKey)
        return (stored?.isEmpty == false) ? stored! : "1007"
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

            // Center the indicators between header and keypad using symmetric spacers
            Spacer(minLength: 0)

            // Indicators
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
        }
        .animation(.easeInOut(duration: 0.15), value: input)
        .task {
            await tryAutoAuthenticate()
        }
    }
    
    // MARK: - Keypad
    private var keypad: some View {
        VStack(spacing: 12) {
            ForEach(Array(keypadRows.enumerated()), id: \.offset) { rowIndex, row in
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

    private var keypadRows: [[String]] {
        [["1","2","3"],["4","5","6"],["7","8","9"],["faceid","0","←"]]
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

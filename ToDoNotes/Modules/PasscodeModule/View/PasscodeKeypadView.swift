//
//  PasscodeKeypadView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI

struct PasscodeKeypadView: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    let onForgot: (() -> Void)?
    let onFaceID: (() -> Void)?
    let showsForgot: Bool
    let showsFaceID: Bool
    let biometricIconName: String

    private let rows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"]
    ]

    var body: some View {
        VStack(spacing: 18) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 26) {
                    ForEach(row, id: \.self) { digit in
                        PasscodeKeyButton(title: digit) {
                            onDigit(digit)
                        }
                    }
                }
            }

            HStack(spacing: 26) {
                if showsFaceID, let onFaceID {
                    Button(action: onFaceID) {
                        Image(systemName: biometricIconName)
                            .font(.system(size: 25, weight: .regular))
                            .foregroundStyle(Color.LabelColors.labelPrimary)
                            .frame(width: 76, height: 76)
                            .background(
                                Circle()
                                    .stroke(Color.LabelColors.labelSecondary, lineWidth: 1)
                            )
                    }
                } else {
                    Spacer()
                        .frame(width: 76, height: 76)
                }

                PasscodeKeyButton(title: "0") {
                    onDigit("0")
                }

                Button(action: onDelete) {
                    Image.Settings.Passcode.delete
                        .frame(width: 76, height: 76)
                        .background(
                            Circle()
                                .stroke(Color.LabelColors.labelSecondary, lineWidth: 1)
                        )
                }
            }

            if showsForgot, let onForgot {
                Button(action: onForgot) {
                    Text(Texts.Passcode.forgot)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color.LabelColors.labelSecondary)
                }
                .padding(.top)
            }
        }
    }
}

private struct PasscodeKeyButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .frame(width: 76, height: 76)
                .background(
                    Circle()
                        .stroke(Color.LabelColors.labelSecondary, lineWidth: 1)
                )
        }
    }
}

#Preview {
    PasscodeKeypadView(
        onDigit: { _ in },
        onDelete: {},
        onForgot: {},
        onFaceID: {},
        showsForgot: true,
        showsFaceID: true,
        biometricIconName: "faceid"
    )
        .padding()
        .background(Color.BackColors.backDefault)
}

//
//  PasscodeManager.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import Foundation
import CryptoKit
import LocalAuthentication
import Security

final class PasscodeManager: ObservableObject {
    @Published private(set) var isLocked: Bool = false
    @Published private(set) var isBiometricsAvailable: Bool = false
    @Published private(set) var biometryType: LABiometryType = .none
    @Published var shouldShowResetAuth: Bool = false

    @Published var isPasscodeEnabled: Bool {
        didSet {
            defaults.set(isPasscodeEnabled, forKey: Texts.UserDefaults.passcodeEnabled)
            if !isPasscodeEnabled {
                isFaceIDEnabled = false
                clearStoredPasscode()
                isLocked = false
            }
        }
    }

    @Published var isFaceIDEnabled: Bool {
        didSet {
            defaults.set(isFaceIDEnabled, forKey: Texts.UserDefaults.faceIDEnabled)
        }
    }

    private let defaults = UserDefaults.standard
    private let keychain = PasscodeKeychainService()
    private let hashKey = "passcode.hash"
    private let saltKey = "passcode.salt"

    init() {
        let enabled = defaults.bool(forKey: Texts.UserDefaults.passcodeEnabled)
        let faceID = defaults.bool(forKey: Texts.UserDefaults.faceIDEnabled)

        self.isPasscodeEnabled = enabled
        self.isFaceIDEnabled = faceID

        refreshBiometricsAvailability()

        if isPasscodeEnabled, !hasStoredPasscode {
            isPasscodeEnabled = false
        }

        isLocked = isPasscodeEnabled && hasStoredPasscode
    }

    var hasStoredPasscode: Bool {
        keychain.data(for: hashKey) != nil && keychain.data(for: saltKey) != nil
    }

    func lockIfNeeded() {
        guard isPasscodeEnabled, hasStoredPasscode else { return }
        isLocked = true
    }

    func unlock(with passcode: String) -> Bool {
        guard verify(passcode: passcode) else { return false }
        isLocked = false
        return true
    }

    func setNewPasscode(_ passcode: String) -> Bool {
        guard passcode.count == 4 else { return false }
        let salt = Self.randomSalt(length: 16)
        let hash = Self.hash(passcode: passcode, salt: salt)
        guard keychain.set(hash, for: hashKey), keychain.set(salt, for: saltKey) else { return false }

        isPasscodeEnabled = true
        isLocked = false
        return true
    }

    func updatePasscode(_ passcode: String) -> Bool {
        setNewPasscode(passcode)
    }

    func clearPasscode() {
        isPasscodeEnabled = false
    }

    func refreshBiometricsAvailability() {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        isBiometricsAvailable = available
        biometryType = context.biometryType

        if !available {
            isFaceIDEnabled = false
        }
    }

    func authenticateWithBiometrics(reason: String, allowWhenDisabled: Bool = false) async -> Bool {
        guard isPasscodeEnabled else { return false }
        if !allowWhenDisabled, !isFaceIDEnabled { return false }

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return false }
        let success = await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { ok, _ in
                continuation.resume(returning: ok)
            }
        }
        if success, !allowWhenDisabled {
            await MainActor.run {
                self.isLocked = false
            }
        }
        return success
    }

    var biometricTitle: String {
        biometryType == .touchID ? Texts.Passcode.touchIdTitle : Texts.Passcode.faceIdTitle
    }

    var biometricReason: String {
        biometryType == .touchID ? Texts.Passcode.touchIdReason : Texts.Passcode.faceIdReason
    }

    var biometricIconName: String {
        biometryType == .touchID ? "touchid" : "faceid"
    }

    var settingsTitle: String {
        String(format: Texts.Passcode.settingsTitleFormat, biometricTitle)
    }

    var descriptionText: String {
        String(format: Texts.Passcode.descriptionFormat, biometricTitle)
    }

    private func verify(passcode: String) -> Bool {
        guard let salt = keychain.data(for: saltKey),
              let storedHash = keychain.data(for: hashKey) else { return false }
        return Self.hash(passcode: passcode, salt: salt) == storedHash
    }

    private func clearStoredPasscode() {
        keychain.delete(hashKey)
        keychain.delete(saltKey)
    }

    private static func hash(passcode: String, salt: Data) -> Data {
        var data = Data()
        data.append(salt)
        data.append(passcode.data(using: .utf8) ?? Data())
        return Data(SHA256.hash(data: data))
    }

    private static func randomSalt(length: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        return Data(bytes)
    }
}

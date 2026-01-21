import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Claude Code credentials not found in Keychain. Make sure Claude Code is installed and you're logged in."
        case .unexpectedData:
            return "Unexpected data format in Keychain."
        case .unhandledError(let status):
            return "Keychain error: \(status)"
        case .decodingError:
            return "Failed to decode credentials from Keychain."
        }
    }
}

final class KeychainHelper: Sendable {
    static let shared = KeychainHelper()

    private let serviceName = "Claude Code-credentials"

    private init() {}

    func getAccessToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = result as? Data else {
            throw KeychainError.unexpectedData
        }

        let decoder = JSONDecoder()
        guard let credentials = try? decoder.decode(ClaudeCredentials.self, from: data),
              let accessToken = credentials.claudeAiOauth?.accessToken else {
            throw KeychainError.decodingError
        }

        return accessToken
    }
}

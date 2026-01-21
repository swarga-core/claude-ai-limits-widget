import Foundation

// MARK: - API Response Models

struct UsageResponse: Codable {
    let fiveHour: UsageLimit?
    let sevenDay: UsageLimit?
    let sevenDayOauthApps: UsageLimit?
    let sevenDayOpus: UsageLimit?
    let sevenDaySonnet: UsageLimit?
    let iguanaNecktie: UsageLimit?
    let extraUsage: ExtraUsage?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOauthApps = "seven_day_oauth_apps"
        case sevenDayOpus = "seven_day_opus"
        case sevenDaySonnet = "seven_day_sonnet"
        case iguanaNecktie = "iguana_necktie"
        case extraUsage = "extra_usage"
    }
}

struct UsageLimit: Codable {
    let utilization: Double
    let resetsAt: String

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }

    var resetDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: resetsAt)
    }

    var timeUntilReset: String {
        guard let resetDate = resetDate else { return "Unknown" }
        let now = Date()

        if resetDate <= now {
            return "Resetting..."
        }

        let interval = resetDate.timeIntervalSince(now)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 24 {
            let days = hours / 24
            let remainingHours = hours % 24
            return "\(days)d \(remainingHours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var resetDateFormatted: String {
        guard let resetDate = resetDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: resetDate)
    }
}

struct ExtraUsage: Codable {
    let isEnabled: Bool
    let monthlyLimit: Double?
    let usedCredits: Double?
    let utilization: Double?

    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case monthlyLimit = "monthly_limit"
        case usedCredits = "used_credits"
        case utilization
    }
}

// MARK: - Keychain Credentials Model

struct ClaudeCredentials: Codable {
    let claudeAiOauth: OAuthTokens?

    struct OAuthTokens: Codable {
        let accessToken: String
        let refreshToken: String
    }
}

// MARK: - View Models

struct UsageDisplayItem: Identifiable {
    let id = UUID()
    let title: String
    let utilization: Double
    let timeUntilReset: String
    let resetDateFormatted: String

    var color: UsageColor {
        switch utilization {
        case 0..<50:
            return .green
        case 50..<80:
            return .yellow
        default:
            return .red
        }
    }

    enum UsageColor {
        case green, yellow, red
    }
}

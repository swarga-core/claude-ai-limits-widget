import Foundation

enum UsageServiceError: Error, LocalizedError {
    case invalidURL
    case noToken
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .noToken:
            return "No access token available."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

@MainActor
final class UsageService: ObservableObject {
    static let shared = UsageService()

    @Published var usageResponse: UsageResponse?
    @Published var error: Error?
    @Published var isLoading = false
    @Published var lastUpdated: Date?

    private let apiURL = "https://api.anthropic.com/api/oauth/usage"
    private let userAgent = "claude-code/2.0.32"
    private let betaHeader = "oauth-2025-04-20"

    private var refreshTimer: Timer?

    private init() {}

    func startAutoRefresh(interval: TimeInterval = 300) { // 5 minutes default
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchUsage()
            }
        }
        // Fetch immediately
        Task {
            await fetchUsage()
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func fetchUsage() async {
        isLoading = true
        error = nil

        do {
            let accessToken = try KeychainHelper.shared.getAccessToken()

            guard let url = URL(string: apiURL) else {
                throw UsageServiceError.invalidURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(betaHeader, forHTTPHeaderField: "anthropic-beta")
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw UsageServiceError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw UsageServiceError.httpError(httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            usageResponse = try decoder.decode(UsageResponse.self, from: data)
            lastUpdated = Date()

        } catch let keychainError as KeychainError {
            error = keychainError
        } catch let usageError as UsageServiceError {
            error = usageError
        } catch let decodingError as DecodingError {
            error = UsageServiceError.decodingError(decodingError)
        } catch {
            self.error = UsageServiceError.networkError(error)
        }

        isLoading = false
    }

    var displayItems: [UsageDisplayItem] {
        guard let response = usageResponse else { return [] }

        var items: [UsageDisplayItem] = []

        if let fiveHour = response.fiveHour {
            items.append(UsageDisplayItem(
                title: "Session (5h)",
                utilization: fiveHour.utilization,
                timeUntilReset: fiveHour.timeUntilReset,
                resetDateFormatted: fiveHour.resetDateFormatted
            ))
        }

        if let sevenDay = response.sevenDay {
            items.append(UsageDisplayItem(
                title: "Weekly (7d)",
                utilization: sevenDay.utilization,
                timeUntilReset: sevenDay.timeUntilReset,
                resetDateFormatted: sevenDay.resetDateFormatted
            ))
        }

        if let sonnet = response.sevenDaySonnet {
            items.append(UsageDisplayItem(
                title: "Sonnet Weekly",
                utilization: sonnet.utilization,
                timeUntilReset: sonnet.timeUntilReset,
                resetDateFormatted: sonnet.resetDateFormatted
            ))
        }

        if let opus = response.sevenDayOpus {
            items.append(UsageDisplayItem(
                title: "Opus Weekly",
                utilization: opus.utilization,
                timeUntilReset: opus.timeUntilReset,
                resetDateFormatted: opus.resetDateFormatted
            ))
        }

        return items
    }

    var menuBarTitle: String {
        guard let response = usageResponse else { return "Claude: --" }

        let fiveHour = response.fiveHour?.utilization ?? 0
        let sevenDay = response.sevenDay?.utilization ?? 0

        return String(format: "5h: %.0f%% | 7d: %.0f%%", fiveHour, sevenDay)
    }
}

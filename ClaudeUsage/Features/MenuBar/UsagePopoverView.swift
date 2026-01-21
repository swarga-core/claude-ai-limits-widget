import SwiftUI

struct UsagePopoverView: View {
    @ObservedObject private var usageService = UsageService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Claude Usage")
                    .font(.headline)
                Spacer()
                if usageService.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            if let error = usageService.error {
                errorView(error)
            } else if usageService.displayItems.isEmpty && !usageService.isLoading {
                emptyView
            } else {
                usageList
            }

            Divider()

            // Footer
            footerView
        }
        .frame(width: 280)
    }

    private var usageList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(usageService.displayItems) { item in
                    UsageItemView(item: item)
                }
            }
            .padding()
        }
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Retry") {
                Task {
                    await usageService.fetchUsage()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No usage data")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Refresh") {
                Task {
                    await usageService.fetchUsage()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footerView: some View {
        HStack {
            Button(action: {
                Task {
                    await usageService.fetchUsage()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .focusable(false)
            .disabled(usageService.isLoading)

            Spacer()

            if let lastUpdated = usageService.lastUpdated {
                Text("Updated \(lastUpdated.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct UsageItemView: View {
    let item: UsageDisplayItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.0f%%", item.utilization))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(colorForUsage)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForUsage)
                        .frame(width: geometry.size.width * (item.utilization / 100), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("Resets in \(item.timeUntilReset)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.resetDateFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private var colorForUsage: Color {
        switch item.color {
        case .green:
            return .green
        case .yellow:
            return .orange
        case .red:
            return .red
        }
    }
}

#Preview {
    UsagePopoverView()
        .frame(width: 280, height: 320)
}

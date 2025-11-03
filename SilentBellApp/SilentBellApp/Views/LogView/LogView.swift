//
//  LogView.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 10/31/25.
//


import SwiftUI

struct LogView: View {
    @StateObject private var viewModel = LogViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView("Loading Logs...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task { await viewModel.fetchLogs() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if viewModel.logs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No logs available")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List(viewModel.logs) { log in
                        HStack(alignment: .top, spacing: 12) {
                            icon(for: log.event_type)
                                .foregroundColor(color(for: log.event_type))
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log.device_name)
                                    .font(.body)
                                Text(log.event_time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .refreshable {
                        await viewModel.fetchLogs()
                    }
                }
            }
            .navigationTitle("Activity Logs")
            .task {
                await viewModel.fetchLogs()
            }
        }
    }
    
    // MARK: - Helpers
    private func icon(for event_type: String) -> Image {
        switch event_type.lowercased() {
        case "error": return Image(systemName: "xmark.octagon.fill")
        case "warning": return Image(systemName: "exclamationmark.triangle.fill")
        default: return Image(systemName: "bell.fill")
        }
    }
    
    private func color(for type: String) -> Color {
        switch type.lowercased() {
        case "error": return .red
        case "warning": return .orange
        default: return .blue
        }
    }
}

#Preview {
    LogView()
}

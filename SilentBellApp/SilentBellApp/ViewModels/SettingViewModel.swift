//
//  SettingViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/30/25.
//
import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings = Preference()
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Load Preferences
    func loadSettings() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await APIService().fetchPreferences()
            settings = fetched
        } catch {
            errorMessage = error.localizedDescription
            print("⚠️ Error fetching preferences:", error)
        }

        isLoading = false
    }

    // MARK: - Save Preferences
    func saveSettings(previousSettings: Preference) async {
        isLoading = true
        errorMessage = nil

        do {
            let updated = try await APIService().updatePreferences(preferences: settings)
            settings = updated
        } catch {
            errorMessage = error.localizedDescription
            print("⚠️ Error updating preferences:", error)
            
            await MainActor.run {
                self.settings = previousSettings
            }

        }

        isLoading = false
    }
}

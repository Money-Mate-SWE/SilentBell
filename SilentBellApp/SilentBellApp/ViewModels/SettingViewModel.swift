//
//  SettingViewModel.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 9/30/25.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings = Preference(pushNotifications: false,
                                           vibrationEnabled: false,
                                           smartLightsEnabled: false)

    @Published var isLoading = false
    @Published var errorMessage: String?

    
    func loadSettings() async {
        isLoading = true
        errorMessage = nil
        do {
            //let fetched = try await APIService.getpref
            //self.settings = fetched
        } //catch {
        //    self.errorMessage = error.localizedDescription
        //}
        isLoading = false
    }

    func saveSettings() async {
        do {
            //try await APIService.updatepref
        } //catch {
        //    self.errorMessage = error.localizedDescription
        //}
    }
}

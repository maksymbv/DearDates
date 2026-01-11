//
//  DataExportImportManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI

struct ExportData: Codable {
    let profiles: [ProfileCodable]
    let gifts: [GiftCodable]
    let userProfile: UserProfileCodable
    let exportDate: Date
    let appVersion: String
    
    init(profiles: [Profile], gifts: [Gift], userProfile: UserProfile) {
        self.profiles = profiles.map { $0.toCodable() }
        self.gifts = gifts.map { $0.toCodable() }
        self.userProfile = userProfile.toCodable()
        self.exportDate = Date()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1"
    }
}

class DataExportImportManager {
    static let shared = DataExportImportManager()
    
    private init() {}
    
    // MARK: - Export
    
    func exportData(profiles: [Profile], gifts: [Gift], userProfile: UserProfile) -> Data? {
        let exportData = ExportData(profiles: profiles, gifts: gifts, userProfile: userProfile)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(exportData)
        } catch {
            AppLogger.log("Error exporting data: \(error.localizedDescription)", level: .error, category: "DataExportImportManager")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
            return nil
        }
    }
    
    func exportToFile(profiles: [Profile], gifts: [Gift], userProfile: UserProfile) -> URL? {
        guard let data = exportData(profiles: profiles, gifts: gifts, userProfile: userProfile) else {
            return nil
        }
        
        let fileName = "DearDates_Export_\(DateFormatter.fileNameFormatter.string(from: Date())).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            AppLogger.log("Error writing export file: \(error.localizedDescription)", level: .error, category: "DataExportImportManager")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
            return nil
        }
    }
    
    // MARK: - Import
    
    func importData(from data: Data) -> (profiles: [ProfileCodable], gifts: [GiftCodable], userProfile: UserProfileCodable)? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let exportData = try decoder.decode(ExportData.self, from: data)
            
            return (exportData.profiles, exportData.gifts, exportData.userProfile)
        } catch {
            AppLogger.log("Error importing data: \(error.localizedDescription)", level: .error, category: "DataExportImportManager")
            ErrorManager.shared.showError(.dataLoadFailed(error.localizedDescription))
            return nil
        }
    }
    
    func importFromFile(at url: URL) -> (profiles: [ProfileCodable], gifts: [GiftCodable], userProfile: UserProfileCodable)? {
        do {
            let data = try Data(contentsOf: url)
            return importData(from: data)
        } catch {
            AppLogger.log("Error reading import file: \(error.localizedDescription)", level: .error, category: "DataExportImportManager")
            ErrorManager.shared.showError(.dataLoadFailed(error.localizedDescription))
            return nil
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}


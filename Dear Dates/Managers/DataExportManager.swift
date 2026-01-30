//
//  DataExportManager.swift
//  DearDates
//
//  Created on 2026
//

import Foundation
import SwiftUI

struct ExportData: Codable {
    let profiles: [ProfileCodable]
    let gifts: [GiftCodable]
    let exportDate: Date
    let appVersion: String
    
    init(profiles: [Profile], gifts: [Gift]) {
        self.profiles = profiles.map { $0.toCodable() }
        self.gifts = gifts.map { $0.toCodable() }
        self.exportDate = Date()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
    }
}

class DataExportManager {
    static let shared = DataExportManager()
    
    private init() {}
    
    // MARK: - Export
    
    func exportData(profiles: [Profile], gifts: [Gift]) -> Data? {
        let exportData = ExportData(profiles: profiles, gifts: gifts)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(exportData)
        } catch {
            AppLogger.log("Error exporting data: \(error.localizedDescription)", level: .error, category: "DataExportManager")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
            return nil
        }
    }
    
    func exportToFile(profiles: [Profile], gifts: [Gift]) -> URL? {
        guard let data = exportData(profiles: profiles, gifts: gifts) else {
            return nil
        }
        
        let fileName = "DearDates_Export_\(DateFormatter.fileNameFormatter.string(from: Date())).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            AppLogger.log("Error writing export file: \(error.localizedDescription)", level: .error, category: "DataExportManager")
            ErrorManager.shared.showError(.dataSaveFailed(error.localizedDescription))
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


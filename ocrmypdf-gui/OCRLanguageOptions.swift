//
//  OCRLanguageOptions.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import Foundation

struct OCRLanguageOptions: RawRepresentable {
    
    static let languages = [
        "chi_sim": "Chinese (Simplified)",
        "chi_tra": "Chinese (Traditional/Cantonese)",
        "nld": "Dutch",
        "eng": "English",
        "fra": "French",
        "deu": "German",
        "pol": "Polish",
        "por": "Portuguese",
    ]
    
    static let defaultLanguage = "eng"
    
    var selected = ["eng", "deu"]
    
    func joinSelectedLanguagesForCommandArgs() -> String {
        let joined = selected.joined(separator: "+")
        return joined
    }
    
    func isNotEmpty() -> Bool {
        return !selected.isEmpty
    }
    
    static func optionToLocalizedString(key: String) -> String {
        return languages[key] ?? OCRLanguageOptions.defaultLanguage
    }
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([String].self, from: data)
        else {
            selected = ["eng"]
            return
        }
        selected = result
        
    }
    
    public init() {
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(selected),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
    
}


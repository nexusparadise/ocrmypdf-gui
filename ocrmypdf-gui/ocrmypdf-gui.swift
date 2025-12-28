//
//  ocrmypdf-gui.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import SwiftUI
import UniformTypeIdentifiers
import AppIntents

@main
struct OCRMyPDFGUIApp: App {
    @StateObject private var ocrTask = OCRTask(activateTestMode:false)
    
    var body: some Scene {
        WindowGroup {
            ContentView(ocrTask: ocrTask)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity, minHeight: 800, idealHeight: 1100, maxHeight: .infinity)
                .onOpenURL(perform: {dropedPdf in ocrTask.runOcrTask(withPdfSource: dropedPdf)})
        }
        
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}

// MARK: - Siri & Shortcuts Integration
struct HelpMeOCRMyPDFIntent: AppIntent {
    static var title: LocalizedStringResource = "Help me ocr my PDF"
    
    static var description = IntentDescription("Runs OCR on your pdf")
    
    @Parameter(title: "Source PDF")
    var sourcePDF: URL
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Create OCRTask on main actor since it's @MainActor isolated
        let task = OCRTask(activateTestMode: false)
        await task.runOcr(pdfSourceUrl: sourcePDF)
        return .result()
    }
}


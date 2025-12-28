//
//  OCRTask.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import SwiftUI
import Collections
import UniformTypeIdentifiers
import Combine

@MainActor
class OCRTask: ObservableObject, DropDelegate {
    var testMode = false
    
    @Published var isRunning = false
    @Published var lockedSettings = false
    @Published var statusMessage: String = "Ready"
    @Published var currentFileIndex: Int = 0
    @Published var totalFiles: Int = 0
    
    @AppStorage("outputPDFA") var outputPDFA = true
    @AppStorage("inPlace") var inPlace = false
    @AppStorage("correctPageRotation") var correctPageRotation = true
    @AppStorage("deskew") var deskew = true
    @AppStorage("rotatePages") var rotatePages = true
    @AppStorage("forceOCR") var forceOCR = true
    @AppStorage("clean") var clean = true
    @AppStorage("compressPDF") var compressPDF = false
    @AppStorage("outputFolder") var outputFolder: String = ""
    @AppStorage("OCRLanguageOptions") var oOCRLanguageOptions = OCRLanguageOptions()
    
    @Published var output : String = ""
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(activateTestMode: Bool = false) {
        self.testMode = activateTestMode
    }
    
    var processedPdfs: Deque<URL> = []
    
    func selectFileAndRunOcrTask() {
        if (!self.testMode) {
            let pdfUrls = self.selectPDF()
            if pdfUrls.isEmpty {
                return
            }
            
            // Process all selected files sequentially
            Task { @MainActor in
                withAnimation {
                    lockedSettings = true
                    isRunning = true
                    totalFiles = pdfUrls.count
                    currentFileIndex = 0
                    statusMessage = "Starting batch of \(pdfUrls.count) file(s)..."
                }
                
                for (index, url) in pdfUrls.enumerated() {
                    let fileNumber = index + 1
                    currentFileIndex = fileNumber
                    statusMessage = "Processing file \(fileNumber) of \(pdfUrls.count)..."
                    await runOcr(pdfSourceUrl: url)
                }
                
                // Keep status visible for a bit before resetting
                isRunning = false
                lockedSettings = false
                statusMessage = "Completed \(pdfUrls.count) file(s)"
                // Keep totalFiles and currentFileIndex visible for a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.currentFileIndex = 0
                    self.totalFiles = 0
                    self.statusMessage = "Ready"
                }
            }
        } else {
            runOcrTask(withPdfSource: nil)
        }
    }
    
    func runOcrTask(withPdfSource: URL?) {
        Task { @MainActor in
            withAnimation {
                lockedSettings = true
                isRunning = true
                totalFiles = 1
                currentFileIndex = 1
                statusMessage = "Processing file 1 of 1..."
            }
            
            if (!self.testMode) {
                await runOcr(pdfSourceUrl: withPdfSource)
            } else {
                try await Task.sleep(until: .now + .seconds(3), clock: .continuous)
            }
            
            // Only reset if this was a single file (not part of a batch)
            if totalFiles <= 1 {
                withAnimation {
                    isRunning = false
                    lockedSettings = false
                    currentFileIndex = 0
                    totalFiles = 0
                }
            }
            // For batch processing, status is managed by the calling function
        }
    }
    
    func runOcr(pdfSourceUrl: URL?) async -> Void {
        guard pdfSourceUrl != nil else {
            return
        }
        
        // Update status based on batch or single file
        if totalFiles > 1 {
            // Keep the batch status message (e.g., "Processing file 2 of 5...")
            // Don't override it during OCR execution
        } else {
            statusMessage = "Initializing OCR..."
        }
        
        // Add separator for multiple files
        if totalFiles > 1 {
            let fileName = pdfSourceUrl!.lastPathComponent
            output += "\n\n" + String(repeating: "=", count: 60) + "\n"
            output += "Processing file: \(fileName)\n"
            output += String(repeating: "=", count: 60) + "\n\n"
        }
        
        let shell = Shell()
        // Track previous shell output length to append only new content
        var previousShellOutputLength = 0
        
        shell.$output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shellOutput in
                guard let self = self else { return }
                // Only append new content that wasn't there before
                if shellOutput.count > previousShellOutputLength {
                    let newContent = String(shellOutput.dropFirst(previousShellOutputLength))
                    self.output += newContent
                    previousShellOutputLength = shellOutput.count
                }
            }
            .store(in: &cancellables)
        
        do {
            // Only update status for single file processing
            if totalFiles <= 1 {
                statusMessage = "Processing PDF..."
            }
            
            try await shell.executeOCR(ocrArgs: optionsToShellArgs(pdfSourceUrl: pdfSourceUrl))
            
            // Clean up the subscription after processing
            cancellables.removeAll()
            
            processedPdfs.prepend(targetUrl(sourceUrl: pdfSourceUrl!, inPlace: inPlace))
            if (processedPdfs.count>10) {
                processedPdfs.removeLast()
            }
            errorMessage = nil
            
            // Only update completion status for single file
            if totalFiles <= 1 {
                statusMessage = "Completed successfully"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.statusMessage = "Ready"
                }
            }
            // For batch processing, status is managed by the calling function
        } catch {
            let nsError = error as NSError
            errorMessage = nsError.localizedDescription
            output += "\n\nError: \(nsError.localizedDescription)\n"
            
            // Update error status, but preserve batch context if applicable
            if totalFiles > 1 {
                statusMessage = "Error processing file \(currentFileIndex) of \(totalFiles): \(nsError.localizedDescription)"
            } else {
                statusMessage = "Error: \(nsError.localizedDescription)"
            }
            print("OCR Error: \(error)")
        }
        
    }
    
    private func optionsToShellArgs(pdfSourceUrl: URL?) -> [String] {
        var args : [String] = []
        
        guard let sourceUrl = pdfSourceUrl else {
            return args
        }
        
        // Build arguments safely - each argument is separate to prevent injection
        if (oOCRLanguageOptions.isNotEmpty()) {
            let languages = oOCRLanguageOptions.joinSelectedLanguagesForCommandArgs()
            // Validate language codes contain only safe characters (letters, numbers, +)
            if languages.range(of: "^[a-zA-Z0-9+]+$", options: .regularExpression) != nil {
                args.append("-l")
                args.append(languages)
            }
        }
        
        if (!outputPDFA) {
            args.append("--output-type")
            args.append("pdf")
        }
        
        // Rotate pages - automatically rotate pages based on detected text
        if (rotatePages) {
            args.append("--rotate-pages")
        }
        
        // Deskew - straighten skewed pages
        if (deskew) {
            args.append("--deskew")
        }
        
        // Force OCR - even if text layer exists
        if (forceOCR) {
            args.append("--force-ocr")
        }
        
        // Clean - remove artifacts
        if (clean) {
            args.append("--clean")
        }
        
        // Compress PDF - use optimize level 2 for compression
        if (compressPDF) {
            args.append("--optimize")
            args.append("2")
        }
        
        let targetUrl = targetUrl(sourceUrl: sourceUrl, inPlace: inPlace)
        
        // Escape file paths properly for shell
        args.append(sourceUrl.path(percentEncoded: false))
        args.append(targetUrl.path(percentEncoded: false))
        
        return args
    }
    
    private func targetUrl(sourceUrl: URL, inPlace: Bool) -> URL {
        if inPlace {
            return sourceUrl
        }
        
        let sourceExtension = sourceUrl.pathExtension
        let sourceName = sourceUrl.deletingPathExtension().lastPathComponent
        
        // Determine output directory
        let outputDir: URL
        if !outputFolder.isEmpty, let folderURL = URL(string: outputFolder) {
            outputDir = folderURL
        } else {
            // Default to Downloads folder
            outputDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first ?? sourceUrl.deletingLastPathComponent()
        }
        
        // Create output filename with " ocr" suffix
        let outputName = sourceName + " ocr"
        return outputDir.appendingPathComponent(outputName).appendingPathExtension(sourceExtension)
    }
    
    func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.message = "Select output folder for OCR'd PDFs"
        
        if panel.runModal() == .OK, let url = panel.url {
            outputFolder = url.absoluteString
        }
    }
    
    func getOutputFolderDisplayName() -> String {
        if !outputFolder.isEmpty, let url = URL(string: outputFolder) {
            return url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent
        }
        return "Downloads"
    }
    
    private func selectPDF () -> [URL] {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK else { return [] }
        return panel.urls
    }
    
    func performDrop(info dropInfo: DropInfo) -> Bool {
        guard dropInfo.hasItemsConforming(to: [UTType.pdf]) else {
            return false
        }
        
        let items = dropInfo.itemProviders(for: [UTType.pdf])
        
        // Process all dropped files sequentially
        Task { @MainActor in
            let totalCount = items.count
            withAnimation {
                lockedSettings = true
                isRunning = true
                totalFiles = totalCount
                currentFileIndex = 0
                statusMessage = "Starting batch of \(totalCount) file(s)..."
            }
            
            var processedCount = 0
            
            for item in items {
                await withCheckedContinuation { continuation in
                    _ = item.loadFileRepresentation(for: UTType.pdf, openInPlace: true) { [self] withDropedPdfSource, success, error in
                        guard success, let url = withDropedPdfSource else {
                            continuation.resume()
                            return
                        }
                        Task { @MainActor in
                            processedCount += 1
                            currentFileIndex = processedCount
                            statusMessage = "Processing file \(processedCount) of \(totalCount)..."
                            await runOcr(pdfSourceUrl: url)
                            continuation.resume()
                        }
                    }
                }
            }
            
            // Keep status visible for a bit before resetting
            isRunning = false
            lockedSettings = false
            statusMessage = "Completed \(totalCount) file(s)"
            // Keep totalFiles and currentFileIndex visible for a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.currentFileIndex = 0
                self.totalFiles = 0
                self.statusMessage = "Ready"
            }
        }
        
        return true
    }
}

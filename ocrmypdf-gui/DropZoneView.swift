//
//  DropZoneView.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @ObservedObject var ocrTask: OCRTask
    @State private var isTargeted = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
                            style: StrokeStyle(lineWidth: isTargeted ? 3 : 2, dash: [10, 5])
                        )
                )
                .frame(height: 120)
            
            VStack(spacing: 12) {
                Image(systemName: isTargeted ? "doc.badge.plus.fill" : "doc.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(isTargeted ? .accentColor : .secondary)
                
                Text(isTargeted ? "Drop PDF(s) here" : "Drag PDF(s) here or click to select")
                    .font(.headline)
                    .foregroundColor(isTargeted ? .accentColor : .primary)
                
                if !isTargeted {
                    Text("Drop one or more PDF files to start OCR processing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            ocrTask.selectFileAndRunOcrTask()
        }
        .onDrop(of: [UTType.pdf], isTargeted: $isTargeted) { providers in
            guard !providers.isEmpty else { return false }
            
            // Process all dropped files as a batch
            Task { @MainActor in
                var urls: [URL] = []
                
                // Load all file URLs first
                await withTaskGroup(of: URL?.self) { group in
                    for provider in providers {
                        group.addTask {
                            await withCheckedContinuation { continuation in
                                _ = provider.loadFileRepresentation(for: UTType.pdf, openInPlace: true) { url, success, error in
                                    continuation.resume(returning: success ? url : nil)
                                }
                            }
                        }
                    }
                    
                    for await url in group {
                        if let url = url {
                            urls.append(url)
                        }
                    }
                }
                
                // Process all files sequentially
                if !urls.isEmpty {
                    ocrTask.lockedSettings = true
                    ocrTask.isRunning = true
                    ocrTask.totalFiles = urls.count
                    ocrTask.currentFileIndex = 0
                    ocrTask.statusMessage = "Starting batch of \(urls.count) file(s)..."
                    
                    for (index, url) in urls.enumerated() {
                        let fileNumber = index + 1
                        ocrTask.currentFileIndex = fileNumber
                        ocrTask.statusMessage = "Processing file \(fileNumber) of \(urls.count)..."
                        await ocrTask.runOcr(pdfSourceUrl: url)
                    }
                    
                    ocrTask.isRunning = false
                    ocrTask.lockedSettings = false
                    ocrTask.statusMessage = "Completed \(urls.count) file(s)"
                    // Keep totalFiles and currentFileIndex visible for a moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        ocrTask.currentFileIndex = 0
                        ocrTask.totalFiles = 0
                        ocrTask.statusMessage = "Ready"
                    }
                }
            }
            return true
        }
    }
}


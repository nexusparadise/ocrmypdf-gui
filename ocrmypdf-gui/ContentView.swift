//
//  ContentView.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import SwiftUI
import Foundation
import Combine

struct ContentView: View {
    
    @ObservedObject var ocrTask: OCRTask
    @State private var showInstallInstructions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // App Title Bar with Glass Effect
            HStack {
                Text("ocrmypdf-gui")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showInstallInstructions.toggle()
                }) {
                    Label("Install ocrmypdf", systemImage: "info.circle")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Installation Instructions (if needed)
                    if showInstallInstructions {
                        InstallationInstructionsView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Process Status Indicator
                    ProcessStatusView(
                        statusMessage: ocrTask.statusMessage,
                        isRunning: ocrTask.isRunning,
                        currentFile: ocrTask.currentFileIndex,
                        totalFiles: ocrTask.totalFiles
                    )
                        .padding(.horizontal, 24)
                        .padding(.top, showInstallInstructions ? 0 : 24)
                    
                    // Drag and Drop Zone
                    DropZoneView(ocrTask: ocrTask)
                        .padding(.horizontal, 24)
                    
                    // Output Folder Selection
                    HStack {
                        Label("Output Folder", systemImage: "folder")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(ocrTask.getOutputFolderDisplayName())
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Button("Change...") {
                            ocrTask.selectOutputFolder()
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                        .disabled(ocrTask.lockedSettings)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Settings Section - Always Visible, Compact
                    VStack(alignment: .leading, spacing: 8) {
                        Label("OCR Settings", systemImage: "gearshape.fill")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        
                        CompactSettingsView()
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Error Message
                    if let errorMessage = ocrTask.errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                    }
                    
                    // Output Log Section - Always Visible
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Output Log", systemImage: "text.bubble")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        
                        SelectableText(text: ocrTask.output.isEmpty ? "No output yet..." : ocrTask.output)
                            .frame(minHeight: 200, maxHeight: 400)
                        
                        // Action Buttons
                        if !ocrTask.processedPdfs.isEmpty && !ocrTask.isRunning {
                            HStack(spacing: 12) {
                                Button(action: {
                                    let pdfURL = ocrTask.processedPdfs[0]
                                    NSWorkspace.shared.open(pdfURL)
                                }) {
                                    Label("Open PDF", systemImage: "doc.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                
                                Button(action: {
                                    let pdfURL = ocrTask.processedPdfs[0]
                                    // Open Finder and select the file
                                    NSWorkspace.shared.activateFileViewerSelecting([pdfURL])
                                }) {
                                    Label("Show in Finder", systemImage: "folder.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// Process Status View - Two Column Layout
struct ProcessStatusView: View {
    let statusMessage: String
    let isRunning: Bool
    let currentFile: Int
    let totalFiles: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Column: Status Icon and Message
            HStack(spacing: 12) {
                if isRunning {
                    ProgressView()
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusMessage)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fontWeight(isRunning ? .medium : .regular)
                    
                    if isRunning && totalFiles > 1 {
                        ProgressView(value: Double(currentFile), total: Double(totalFiles))
                            .progressViewStyle(.linear)
                            .frame(height: 6)
                            .tint(.accentColor)
                    }
                }
            }
            
            Spacer()
            
            // Right Column: File Counter - Always show when totalFiles > 0
            if totalFiles > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(isRunning ? "File" : "Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isRunning {
                        Text("\(currentFile) of \(totalFiles)")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    } else {
                        Text("\(totalFiles) file\(totalFiles == 1 ? "" : "s")")
                            .font(.title3)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isRunning ? Color.accentColor.opacity(0.1) : Color.green.opacity(0.1))
                .cornerRadius(8)
            } else if isRunning {
                // Show progress even if totalFiles is 0 (single file processing)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Processing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ProgressView()
                        .scaleEffect(0.8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Selectable Text View with Live Updates
struct SelectableText: NSViewRepresentable {
    let text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        textView.backgroundColor = .clear
        textView.textColor = .labelColor
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        let wasAtBottom = isScrolledToBottom(scrollView: nsView)
        let wasEmpty = textView.string.isEmpty
        
        // Only update if text actually changed
        if textView.string != text {
            textView.string = text
            
            // Auto-scroll to bottom if user was already at bottom (for live updates)
            if wasAtBottom || wasEmpty {
                DispatchQueue.main.async {
                    self.scrollToBottom(scrollView: nsView)
                }
            }
        }
    }
    
    private func isScrolledToBottom(scrollView: NSScrollView) -> Bool {
        guard let documentView = scrollView.documentView else { return true }
        let visibleRect = scrollView.documentVisibleRect
        let maxY = documentView.bounds.maxY
        return visibleRect.maxY >= maxY - 10 // 10px threshold
    }
    
    private func scrollToBottom(scrollView: NSScrollView) {
        guard let documentView = scrollView.documentView else { return }
        let maxY = documentView.bounds.maxY
        let point = NSPoint(x: 0, y: maxY)
        documentView.scroll(point)
    }
}

// Compact Settings View with 2 Columns
struct CompactSettingsView: View {
    @AppStorage("outputPDFA") var outputPDFA = true
    @AppStorage("inPlace") var inPlace = false
    @AppStorage("correctPageRotation") var correctPageRotation = true
    @AppStorage("deskew") var deskew = true
    @AppStorage("rotatePages") var rotatePages = true
    @AppStorage("forceOCR") var forceOCR = true
    @AppStorage("clean") var clean = true
    @AppStorage("compressPDF") var compressPDF = false
    @AppStorage("OCRLanguageOptions") var oOCRLanguageOptions = OCRLanguageOptions()
    
    var body: some View {
        VStack(spacing: 8) {
            // 3-Column Toggle Grid for more compact layout
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 4),
                GridItem(.flexible(), spacing: 4),
                GridItem(.flexible(), spacing: 4)
            ], spacing: 6) {
                CompactToggle(label: "PDF/A", isOn: $outputPDFA)
                CompactToggle(label: "In Place", isOn: $inPlace)
                CompactToggle(label: "Deskew", isOn: $deskew)
                CompactToggle(label: "Rotate Pages", isOn: $rotatePages)
                CompactToggle(label: "Force OCR", isOn: $forceOCR)
                CompactToggle(label: "Clean", isOn: $clean)
                CompactToggle(label: "Compress", isOn: $compressPDF)
                CompactToggle(label: "Correct Rotation", isOn: $correctPageRotation)
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // Language Selection
            MultiSelector(
                label: "Languages:",
                options: OCRLanguageOptions.languages,
                optionToString: OCRLanguageOptions.optionToLocalizedString,
                selected: $oOCRLanguageOptions.selected
            )
        }
    }
}

// Compact Toggle Component
struct CompactToggle: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
            Text(label)
                .font(.system(.caption2))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(6)
    }
}

struct InstallationInstructionsView: View {
    @State private var copiedOcrmypdf = false
    @State private var copiedTesseract = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Install Dependencies")
                    .font(.headline)
                Spacer()
            }
            
            Text("To use this app, you need to install ocrmypdf and tesseract-lang via Homebrew:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("brew install ocrmypdf")
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString("brew install ocrmypdf", forType: .string)
                        copiedOcrmypdf = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedOcrmypdf = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: copiedOcrmypdf ? "checkmark" : "doc.on.doc")
                            Text(copiedOcrmypdf ? "Copied!" : "Copy")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
                
                HStack {
                    Text("brew install tesseract-lang")
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString("brew install tesseract-lang", forType: .string)
                        copiedTesseract = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedTesseract = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: copiedTesseract ? "checkmark" : "doc.on.doc")
                            Text(copiedTesseract ? "Copied!" : "Copy")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            Text("After installation, restart this app and try processing a PDF.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var ocrTask = OCRTask()
    
    static var previews: some View {
        ContentView(ocrTask: ocrTask)
    }
}


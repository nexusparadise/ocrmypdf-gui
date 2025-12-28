//
//  SettingsView.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import SwiftUI

struct SettingsView: View {
    private let settingsIcon = "gearshape.fill"
    
    private enum Tabs: Hashable {
        case general, advanced
    }
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("OCR Settings", systemImage: settingsIcon)
                }
                .tag(Tabs.general)
            //                AdvancedSettingsView()
            //                    .tabItem {
            //                        Label("Advanced", systemImage: "star")
            //                    }
            //                    .tag(Tabs.advanced)
        }
        .padding(20)
        .frame(width: 400, height: 450)
    }
}

struct GeneralSettingsView: View {
    
    @AppStorage("outputPDFA") var outputPDFA = true
    @AppStorage("inPlace") var inPlace = false
    @AppStorage("correctPageRotation") var correctPageRotation = true
    @AppStorage("deskew") var deskew = true
    @AppStorage("rotatePages") var rotatePages = true
    @AppStorage("forceOCR") var forceOCR = true
    @AppStorage("clean") var clean = true
    @AppStorage("outputFolder") var outputFolder: String = ""
    @AppStorage("OCRLanguageOptions") var oOCRLanguageOptions = OCRLanguageOptions()
    
    var body: some View {
        VStack(spacing: 16) {
            Form {
                Toggle("Output PDF/A", isOn: $outputPDFA)
                    .toggleStyle(.switch)
                Toggle("In Place", isOn: $inPlace)
                    .toggleStyle(.switch)
                Toggle("Correct Page Rotation", isOn: $correctPageRotation)
                    .toggleStyle(.switch)
                Toggle("Rotate Pages", isOn: $rotatePages)
                    .toggleStyle(.switch)
                Toggle("Deskew", isOn: $deskew)
                    .toggleStyle(.switch)
                Toggle("Force OCR", isOn: $forceOCR)
                    .toggleStyle(.switch)
                Toggle("Clean", isOn: $clean)
                    .toggleStyle(.switch)
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Label("Output Folder:", systemImage: "folder")
                    Spacer()
                    Text(outputFolder.isEmpty ? "Downloads" : (URL(string: outputFolder)?.lastPathComponent ?? "Downloads"))
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Button("Change...") {
                        selectOutputFolder()
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                }
                
                MultiSelector(
                    label: "Languages:",
                    options: OCRLanguageOptions.languages,
                    optionToString: OCRLanguageOptions.optionToLocalizedString,
                    selected: $oOCRLanguageOptions.selected
                )
            }
            HStack () {
                Button(action: resetSettings) {
                    Label("Reset Settings", systemImage: "gearshape.arrow.triangle.2.circlepath")
                        .font(Font.footnote)
                }.buttonStyle(.link)
                
                Spacer()
            }
        }
        
    }
    
    func resetSettings() {
        outputPDFA = true
        inPlace = false
        correctPageRotation = true
        deskew = true
        rotatePages = true
        forceOCR = true
        clean = true
        outputFolder = ""
        oOCRLanguageOptions.selected = ["eng", "deu"]
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

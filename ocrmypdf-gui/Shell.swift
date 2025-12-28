//
//  Shell.swift
//  ocrmypdf-gui
//
//  Created by Ralf Eisenreich on 27.12.25.
//

import Foundation
import SwiftUI

class Shell: ObservableObject, @unchecked Sendable {
    @Published var output: String = ""
    @Published var errorMessage: String? = nil
    private let _environmentPath = EnvironmentPath()
    
    /// Checks if ocrmypdf is available in the system PATH
    func checkOCRMyPDFAvailable() async -> Bool {
        do {
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/which")
            process.arguments = ["ocrmypdf"]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            var environment = ProcessInfo.processInfo.environment
            environment["PATH"] = _environmentPath.colonJoinedEnvironmentPath
            process.environment = environment
            
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            return process.terminationStatus == 0 && !output.isEmpty && FileManager.default.fileExists(atPath: output)
        } catch {
            return false
        }
    }
    
    func executeOCR(ocrArgs: [String]) async throws -> Void {
        // Clear previous error
        await MainActor.run {
            self.errorMessage = nil
        }
        
        // Verify ocrmypdf is available first
        guard await checkOCRMyPDFAvailable() else {
            let error = NSError(domain: "Shell", code: 1, userInfo: [NSLocalizedDescriptionKey: "ocrmypdf not found. Please install it using: brew install ocrmypdf"])
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
        
        // Build command with proper escaping - each argument is already properly formatted
        // We need to join them for the shell command, but they're already validated
        let escapedArgs = ocrArgs.map { arg in
            // Escape single quotes and wrap in quotes if needed
            if arg.contains(" ") || arg.contains("'") || arg.contains("\"") {
                return "'\(arg.replacingOccurrences(of: "'", with: "'\\''"))'"
            }
            return arg
        }
        
        let args = ["-ic", "ocrmypdf " + escapedArgs.joined(separator: " ")]
        try await _execute(command: "/bin/zsh", arguments: args)
    }
    
    private func _execute(command: String, arguments: [String] = []) async throws -> Void {
        
        
        let process = Process()
        process.executableURL = URL(filePath: command)
        process.arguments = arguments
        
        let pipe = Pipe()
        
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = _environmentPath.colonJoinedEnvironmentPath
        print(environment["PATH"] ?? "No Path")
        self.output += "PATH = \(environment["PATH"] ?? "") \n"
        
        process.environment = environment
        
        process.standardOutput = pipe
        process.standardError = pipe
        
        print(command+" "+arguments.joined(separator: " "))
        self.output += "Run Command: \(command) \(arguments.joined(separator: " ")) \n"
        
        pipe.fileHandleForReading.readabilityHandler = { [weak self] pipe in
            guard let self = self else { return }
            if let pipeDataAsString = String(data: pipe.availableData, encoding: .utf8) {
                if !pipeDataAsString.isEmpty {
                    DispatchQueue.main.async {
                        self.output += pipeDataAsString
                    }
                    print("----> ouput: \(pipeDataAsString)")
                }
            } else {
                print("Error decoding data: \(pipe.availableData)")
            }
        }
        
        try process.run()
        process.waitUntilExit()
        
        // Remove readability handler to prevent further callbacks
        pipe.fileHandleForReading.readabilityHandler = nil
        
        // Read any remaining output
        let remainingData = pipe.fileHandleForReading.readDataToEndOfFile()
        if let remainingOutput = String(data: remainingData, encoding: .utf8), !remainingOutput.isEmpty {
            await MainActor.run {
                self.output += remainingOutput
            }
        }
        
        // Check for errors
        if process.terminationStatus != 0 {
            let currentOutput = await MainActor.run {
                return self.output
            }
            let errorOutput = currentOutput.isEmpty ? "Process exited with code \(process.terminationStatus)" : currentOutput
            let error = NSError(domain: "Shell", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: errorOutput])
            await MainActor.run {
                self.errorMessage = errorOutput
            }
            throw error
        }
    }
    
}

struct EnvironmentPath {
    private static let DefaultPaths = "/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/homebrew/bin"
    private var paths: Set<String> = []
    
    init() {
        let defaultPaths = EnvironmentPath.DefaultPaths.split(separator: ":", maxSplits: Int.max, omittingEmptySubsequences: true).map { String($0) }
        let envPaths = EnvironmentPath.getEnvironmentPath().split(separator: ":", maxSplits: Int.max, omittingEmptySubsequences: true).map { String($0) }.filter({ !$0.isEmpty })
        
        paths.formUnion(defaultPaths)
        paths.formUnion(envPaths)
    }
    
    private static func getEnvironmentPath() -> String {
        let environment = ProcessInfo.processInfo.environment
        guard let environmentPath = environment["PATH"] else { return "" }
        return environmentPath
    }
    
    var colonJoinedEnvironmentPath: String {
        return paths.joined(separator: ":")
    }
}

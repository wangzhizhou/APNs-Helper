//
//  Finder+P8.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#endif

struct Finder {
    static func chooseP8AndDecrypt() -> (output: String?, error: String?) {
#if os(macOS)
        let openPanel = NSOpenPanel()
        openPanel.prompt = "选择"
        if let p8UTType = UTType(filenameExtension: "p8") {
            openPanel.allowedContentTypes = [p8UTType]
        }
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.runModal()
        if let p8FileURL = openPanel.url {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
            process.arguments = [
                "pkcs8",
                "-nocrypt",
                "-in",
                "\(p8FileURL.path)"
            ]
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            try? process.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8)
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let error = String(data: errorData, encoding: .utf8)
            return (output: output, error: error)
        }
        return (nil, "no p8 file be selected!\n")
#else
        return (nil, nil)
#endif
        
    }
}

//
//  CodeFormatter.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

import SwiftUI

/// https://github.com/raspu/Highlightr
import Highlightr

/// https://github.com/simonbs/Prettier
import Prettier
import PrettierBabel

struct CodeFomater {
    
    enum Language: String {
        case json
    }
    
    static func highlightTextContainer(language: Language? = nil) -> NSTextContainer {
        let textStorage = CodeAttributedString(highlightr: highlighter)
        textStorage.highlightr.ignoreIllegals = true
        textStorage.language = language?.rawValue
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        
        return textContainer
    }
    
    static let highlighter: Highlightr = {
        let highlighter = Highlightr()!
        highlighter.ignoreIllegals = true
        return highlighter
    }()
    
    static func resetTheme(colorScheme: ColorScheme) {
        let themeName = colorScheme == .dark ? "vs2015" : "github"
        highlighter.setTheme(to: themeName)
    }
    
    static let jsonFormatter: PrettierFormatter = {
        let formatter = PrettierFormatter(plugins: [BabelPlugin()], parser: JSONParser())
        formatter.prepare()
        return formatter
    }()
    
    static func setup() {
        _ = highlighter
        _ = jsonFormatter
    }
    
    static func format(_ code: String, language: Language? = nil) throws -> String {
        
        guard let language = language else {
            return code
        }
        
        var formatter: PrettierFormatter?
        switch language {
        case .json:
            formatter = jsonFormatter
        }
        
        guard let formatter = formatter else {
            return code
        }
        
        let ret = formatter.format(code)
        switch ret {
        case .success(let formattedCode):
            return formattedCode
        case .failure(let error):
            throw error
        }
    }
}

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

    static var lightColorSheme: String = "github"

    static var darkColorSheme: String = "vs2015"

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
        let themeName = colorScheme == .dark ? darkColorSheme : lightColorSheme
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

    static func format(_ code: String, cursorPosition: Int = 0, language: Language? = nil) throws -> FormatWithCursorResult? {

        guard let language = language else {
            return nil
        }

        var formatter: PrettierFormatter?
        switch language {
        case .json:
            formatter = jsonFormatter
        }

        guard let formatter = formatter else {
            return nil
        }

        let ret = formatter.format(code, withCursorAtLocation: cursorPosition)
        switch ret {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }
}

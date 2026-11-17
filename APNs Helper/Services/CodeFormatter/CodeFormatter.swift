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

    static let lightColorSheme: String = "github"

    static let darkColorSheme: String = "vs2015"

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

    /// Highlightr 内部持有可变状态，且只在主线程（编辑器）使用，
    /// Swift 6 下用 `nonisolated(unsafe)` 显式声明这条既有约定。
    nonisolated(unsafe) static let highlighter: Highlightr = {
        let highlighter = Highlightr()!
        highlighter.ignoreIllegals = true
        return highlighter
    }()

    static func resetTheme(colorScheme: ColorScheme) {
        let themeName = colorScheme == .dark ? darkColorSheme : lightColorSheme
        highlighter.setTheme(to: themeName)
    }

    /// 同上：Prettier 的 formatter 非线程安全，只在格式化时串行使用。
    nonisolated(unsafe) static let jsonFormatter: PrettierFormatter = {
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

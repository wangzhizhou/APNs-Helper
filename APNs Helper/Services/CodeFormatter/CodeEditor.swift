//
//  CodeEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

import SwiftUI

struct CodeEditor: View {
    
    @Binding var content: String
    
    var language: CodeFomater.Language? = .json
    
    var onError: ((Error?) -> Void)? = nil
    
    var body: some View {
        Group {
            GeometryReader { geometry in
#if os(macOS)
                MacOSCodeEditor(
                    content: $content,
                    language: language,
                    size: geometry.size,
                    onError: onError
                )
#elseif os(iOS)
                iOSCodeEditor(
                    content: $content,
                    language: language,
                    size: geometry.size,
                    onError: onError
                )
#endif
            }
        }
    }
}

struct CodeEditor_Previews: PreviewProvider {
    
    @State static var error: Error? = nil
    
    static var previews: some View {
        Group {
            VStack {
                GroupBox("Invalid JSON") {
                    CodeEditor(content: .constant("""
                    {
                    "h1":
                    }
                    """))
                    
                }
                
                GroupBox("Valid JSON") {
                    CodeEditor(content: .constant("""
                    {
                    "h1": 1
                    }
                    """))
                }
            }
        }
        .padding()
        .previewDevice("My Mac")
        .previewDisplayName("MacOS")
        
        
        Group {
            VStack {
                GroupBox("Invalid JSON") {
                    CodeEditor(content: .constant("""
                    {
                    "h1":
                    }
                    """))
                    
                }
                
                GroupBox("Valid JSON") {
                    CodeEditor(content: .constant("""
                    {
                    "h1": 1
                    }
                    """))
                }
            }
        }
        .previewDevice("iPhone 14 Pro Max")
        .previewDisplayName("iOS")
    }
}

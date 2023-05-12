//
//  PayloadEditor.swift
//  APNs Helper
//
//  Created by joker on 2023/5/12.
//

import SwiftUI


struct PayloadEditor: View {
    
    @EnvironmentObject var appModel: AppModel
    
    var title: String? = nil
    
    @Binding var payload: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
            }
            CodeEditor(content: $payload) { error in
                DispatchQueue.main.async {
                    appModel.resetLog()
                    if let error = error {
                        appModel.appLog.append(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct PayloadEditor_Previews: PreviewProvider {
    static var previews: some View {
        PayloadEditor(
            payload: .constant("""
            {
            "aps": {
            "title": "title content"
            }
            }
            """))
    }
}

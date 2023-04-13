//
//  ContentView.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: TesterAppModel
    
    var body: some View {
        
        let content = [
            ("Key ID", model.keyId),
            ("Team ID", model.teamID),
            ("BundleID", model.bundleId),
            ("Device Token", model.deviceToken),
            ("PushKit Device Token", model.pushKitToken),
            ("P8 Key", model.P8Key)
        ]
        
        Form {
            ForEach(content, id: \.self.0) { item in
                Section(item.0) {
                    ItemEntry(title: item.1, alertMessage: $model.alertMessage)
                }
            }
            
            
        }
        .alert(isPresented: $model.showAlert, content: {
            Alert(title: Text(model.alertMessage), message: Text(UIPasteboard.general.string ?? ""))
        })
    }
}

struct ItemEntry: View {
    
    let title: String
    
    @Binding var alertMessage: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button {
                UIPasteboard.general.string = title
                alertMessage = "Copyed To Pasteboard!"
            } label: {
                Image(systemName: "doc.on.doc.fill")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TesterApp.model)
    }
}

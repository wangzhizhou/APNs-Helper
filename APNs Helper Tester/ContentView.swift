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
        
        VStack {
            
            Button {
                model.copyToPasteboard(content: model.deviceToken)
                model.alertMessage = "Device Token has be copyed into Pasteboard"
            } label: {
                HStack(alignment: .top) {
                    Text("DeviceToken:")
                    Text(model.deviceToken)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding([.bottom], 20)
            
            
            Button {
                model.copyToPasteboard(content: model.pushKitToken)
                model.alertMessage = "PushKit Token has be copyed into Pasteboard"
            } label: {
                HStack(alignment: .top) {
                    Text("PushKitToken:")
                    Text(model.pushKitToken)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding([.bottom], 20)
            
        }
        .alert(isPresented: $model.showAlert, content: {
            Alert(title: Text(model.alertMessage), message: Text(UIPasteboard.general.string ?? ""))
        })
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TesterApp.model)
    }
}

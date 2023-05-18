//
//  ContentView.swift
//  APNs Helper Tester
//
//  Created by joker on 2022/11/30.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    
    @EnvironmentObject var model: TesterAppModel
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(model.content, id: \.self.0) { item in
                    Section(item.0) {
                        ItemEntry(title: item.1)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .toolbar(content: {
                Button {
                    model.copyAllInfo()
                } label: {
                    Text("Copy All")
                }
                .buttonStyle(.bordered)
            })
            .navigationTitle("APNs Tester App")
            .alert(isPresented: $model.showAlert, content: {
                Alert(title: Text(model.alertMessage))
            })
        }
        .toast(isPresenting: $model.showToast) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: model.toastMessage
            )
        }
    }
}

struct ItemEntry: View {
    
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button {
                title.copyToPasteboard()
            } label: {
                Image(systemName: "doc.on.doc.fill")
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TesterAppModel())
    }
}

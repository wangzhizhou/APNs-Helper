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
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack {
#if os(iOS)
                Form {
                    ForEach(model.content.filter {
                        !$0.1.isEmpty
                    }, id: \.self.0) { item in
                        Section(item.0) {
                            ItemEntry(title: item.1)
                        }
                    }
                }
#endif

#if os(macOS)
                ScrollView {
                    ForEach(model.content.filter { !$0.1.isEmpty }, id: \.self.0) { item in
                        GroupBox(item.0) {
                            ItemEntry(title: item.1)
                        }
                    }
                }
                .padding()
#endif
            }
            .scrollIndicators(.hidden)
            .toolbar(content: {
                Button {
                    model.copyAllInfo()
                } label: {
                    Text("Copy All as JSON")
                }
                .buttonStyle(.bordered)
            })
            .navigationTitle("APNs Tester App")
        }
        .alert(isPresented: $model.showAlert, content: {
            Alert(title: Text(model.alertMessage))
        })
        .toast(isPresenting: $model.showToast) {
            AlertToast(
                displayMode: model.toastModel.mode,
                type: model.toastModel.type,
                title: model.toastModel.title,
                subTitle: model.toastModel.subtitle,
                style: model.toastModel.style)
        }
        .onReceive(timer) { _ in
            model.checkReceiveLocationNotification()
        }
        .onAppear {
            model.startLiveActivity()
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

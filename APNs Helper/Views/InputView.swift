//
//  InputView.swift
//  APNs Helper
//
//  Created by joker on 2022/9/28.
//

import SwiftUI

struct InputView: View {

    @EnvironmentObject var appModel: AppModel

    let title: String

    var placeholder: String?

    var titleWidth: CGFloat?

    @Binding var inputValue: String

    @FocusState private var focusState: Bool

    var body: some View {
        HStack {
            Text(title)
                .frame(width: titleWidth, alignment: .leading)
            VStack {
                TextField(placeholder ?? title, text: $inputValue)
                    .focused($focusState)
                    .onSubmit {
                        focusState = false
                    }
                    .onChange(of: inputValue) { _, newValue in
                        let trimmedValue = newValue.replacingOccurrences(of: " ", with: "")
                        guard trimmedValue == newValue else {
                            inputValue = trimmedValue
                            return
                        }
                    }
#if os(iOS)
                    .keyboardType(.asciiCapable)
                    .textFieldUnderLine()
#elseif os(macOS)
                    .textFieldBorder()
#endif
            }
#if os(iOS)

            if !inputValue.isEmpty {
                HStack {
                    Button {
                        inputValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    Button {
                        inputValue.copyToPasteboard()
                    } label: {
                        Image(systemName: "doc.on.doc.fill")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
#endif
        }
    }
}

struct InputView_Previews: PreviewProvider {

    @State static var value: String = ""

    static var previews: some View {

        let titleWidth: CGFloat = 60

        VStack {
            InputView(
                title: Constants.keyid.value,
                titleWidth: titleWidth,
                inputValue: $value)

            InputView(
                title: Constants.teamid.value,
                titleWidth: titleWidth,
                inputValue: $value)

            InputView(
                title: Constants.bundleid.value,
                titleWidth: titleWidth,
                inputValue: $value)
        }
        .padding()
    }
}

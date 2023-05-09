//
//  TokenView.swift
//  APNs Helper
//
//  Created by joker on 2023/5/9.
//

import SwiftUI

struct TokenView: View {
    
    let pushType: PushType
    
    @Binding var deviceToken: String
    @Binding var pushKitDeviceToken: String
    
    var body: some View {
        if pushType == .alert || pushType == .background {
            InputView(
                title: Constants.devicetoken.value,
                inputValue: $deviceToken)
        } else if pushType == .voip {
            InputView(
                title: Constants.pushkittoken.value,
                inputValue: $pushKitDeviceToken)
        }
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            VStack {
                
                TokenView(
                    pushType: .alert,
                    deviceToken: .constant("alert device token"),
                    pushKitDeviceToken: .constant("push kit token"))
                
                TokenView(
                    pushType: .background,
                    deviceToken: .constant("background device token"),
                    pushKitDeviceToken: .constant("push kit token"))
                
                
                TokenView(
                    pushType: .voip,
                    deviceToken: .constant("void push kit token"),
                    pushKitDeviceToken: .constant("push kit token"))
            }
            .padding()
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")
            
            
            Form {
                TokenView(
                    pushType: .alert,
                    deviceToken: .constant("alert device token"),
                    pushKitDeviceToken: .constant("push kit token"))
                
                TokenView(
                    pushType: .background,
                    deviceToken: .constant("background device token"),
                    pushKitDeviceToken: .constant("push kit token"))
                
                
                TokenView(
                    pushType: .voip,
                    deviceToken: .constant("void push kit token"),
                    pushKitDeviceToken: .constant("push kit token"))
            }
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
    }
}

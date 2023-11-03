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
    @Binding var fileProviderDeviceToken: String
    @Binding var locationPushServiceToken: String

    var body: some View {
        switch pushType {
        case .alert, .background:
            InputView(
                title: Constants.devicetoken.value,
                inputValue: $deviceToken)
        case .voip:
            InputView(
                title: Constants.voiptoken.value,
                inputValue: $pushKitDeviceToken)
        case .fileprovider:
            InputView(
                title: Constants.fileprovidertoken.value,
                inputValue: $fileProviderDeviceToken)
        case .location:
            InputView(
                title: Constants.locationPushServiceToken.value,
                inputValue: $locationPushServiceToken)
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
                    pushKitDeviceToken: .constant("push kit token"),
                    fileProviderDeviceToken: .constant("file provider token"),
                    locationPushServiceToken: .constant("location push token")
                )

                TokenView(
                    pushType: .background,
                    deviceToken: .constant("background device token"),
                    pushKitDeviceToken: .constant("push kit token"),
                    fileProviderDeviceToken: .constant("file provider token"),
                    locationPushServiceToken: .constant("location push token")
                )

                TokenView(
                    pushType: .voip,
                    deviceToken: .constant("void push kit token"),
                    pushKitDeviceToken: .constant("push kit token"),
                    fileProviderDeviceToken: .constant("file provider token"),
                    locationPushServiceToken: .constant("location push token")
                )
            }
            .padding()
            .previewDevice("My Mac")
            .previewDisplayName("MacOS")

            Form {
                TokenView(
                    pushType: .alert,
                    deviceToken: .constant("alert device token"),
                    pushKitDeviceToken: .constant("push kit token"),
                    fileProviderDeviceToken: .constant("file provider token"),
                    locationPushServiceToken: .constant("location push token")
                )

                TokenView(
                    pushType: .background,
                    deviceToken: .constant("background device token"),
                    pushKitDeviceToken: .constant("push kit token"),
                    fileProviderDeviceToken: .constant("file provider token"),
                    locationPushServiceToken: .constant("location push token")
                )

                TokenView(
                    pushType: .voip,
                    deviceToken: .constant("void push kit token"),
                    pushKitDeviceToken: .constant("push kit token"),
                    fileProviderDeviceToken: .constant("file provider token"),
                    locationPushServiceToken: .constant("location push token")
                )
            }
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iOS")
        }
    }
}

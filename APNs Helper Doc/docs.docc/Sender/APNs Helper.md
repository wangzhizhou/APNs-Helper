# APNs Helper

@Metadata {
    @PageImage(purpose: card, source: sender)
}

A tool that can run on MacOS/iOS device, you can use it to send apns notifications.

## Overview

This app can be installed by clicking the app icon bellow.

[![App Icon](sender)](https://apps.apple.com/cn/app/apns-helper/id6443608175)

### Features

- [x] Supported push type: 
    - **[alert][alert push]**
    - **[background][background push]**
    - **[voip][voip push]**
    - **[fileprovider][file provider push]**
    - **[location][location push]**
    - **[liveactivity][liveactivity push]**
- [x] Custom json payload configuration
- [x] Support json formatting and highlighting for payload 
- [x] Import **`*.p8`** file from file system or input private key content manually 
- [x] Display runtime log while sending push
- [x] Save the filled app info as preset config
- [x] **`⌘+⏎`** keyboard shortcut to trigger send button on macOS App
- [x] **`⌘+T`** keyboard shortcut to load default payload template on macOS App if you clear payload

### Todos

- [ ] Mutable Content Alert Push
- [ ] Custom Category Alert Push
- [ ] Threaded Alert Push
- [ ] Localized Alert Push

[alert push]: <https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification>
[background push]: <https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app>
[voip push]: <https://developer.apple.com/documentation/pushkit/supporting_pushkit_notifications_in_your_app>
[file provider push]: <https://developer.apple.com/documentation/fileprovider/nonreplicated_file_provider_extension/content_and_change_tracking/tracking_your_file_provider_s_changes/using_push_notifications_to_signal_changes>
[location push]: <https://developer.apple.com/documentation/corelocation/creating_a_location_push_service_extension/>
[liveactivity push]: <https://developer.apple.com/documentation/activitykit/updating-and-ending-your-live-activity-with-activitykit-push-notifications> 

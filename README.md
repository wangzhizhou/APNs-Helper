[![App Icon](https://github.com/wangzhizhou/APNs-Helper/blob/main/APNs%20Helper/Resources/Assets.xcassets/AppIcon.appiconset/mac256.png)](https://apps.apple.com/cn/app/apns-helper/id6443608175)

# APNs-Helper

A Tool run on MacOS/iOS that can send APNs Notifications for Test

[APNs Helper Doc Site](https://wangzhizhou.github.io/APNs-Helper-Doc/documentation/apns_helper_doc/)

[The Figma Design](https://www.figma.com/file/sLVIKqiYfxHNb7gUnOUZ9x/APNs-Helper-And-Tester?type=design&mode=design&t=Zw15LS2GJSaFmGbL-1F)

## Development

Requirements: Xcode 16 or newer (iOS 17 / macOS 14 deployment targets).

```bash
# 依赖（SwiftPM，含 APNSwift）
xcodebuild -resolvePackageDependencies -project "APNs Helper.xcodeproj" -scheme "APNs Helper"

# 构建（macOS / iOS 模拟器）
xcodebuild build -project "APNs Helper.xcodeproj" -scheme "APNs Helper" -destination 'platform=macOS'
xcodebuild build -project "APNs Helper.xcodeproj" -scheme "APNs Helper" -destination 'generic/platform=iOS Simulator'

# 单元测试（Swift Testing）
xcodebuild test -project "APNs Helper.xcodeproj" -scheme "APNs Helper Tests" -destination 'platform=macOS'

# 代码规范（规则见 .swiftlint.yml）
brew install swiftlint && swiftlint lint --config .swiftlint.yml --quiet
```

## Dependencies

| 依赖 | 用途 |
| --- | --- |
| [APNSwift](https://github.com/kylebrowning/APNSwift) | 与 APNs 通信（JWT 鉴权、HTTP/2 请求） |
| [AlertToast](https://github.com/elai950/AlertToast) | Toast 提示 |
| [Highlightr](https://github.com/raspu/Highlightr) | Payload 编辑器 JSON 高亮 |
| [Prettier](https://github.com/simonbs/Prettier) | Payload 编辑器 JSON 格式化 |

`Package.resolved` 已入库，请勿手工修改版本；升级统一通过 Xcode 的 *Package Dependencies* 面板完成。

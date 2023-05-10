//
//  Constants.swift
//  APNs Helper
//
//  Created by joker on 2023/4/28.
//

import Foundation


/// 定义应用中所有的字符串相关的常量
enum Constants: String {
    case preset = "Preset"
    case presetnone = "none"
    case clearallpreset = "Clear All Preset"
    case pushtype = "Push Type"
    case apnserver = "APN Server"
    case keyid = "KeyId"
    case teamid = "TeamID"
    case bundleid = "BundleID"
    case devicetoken = "DeviceToken"
    case pushkittoken = "PushKitToken"
    case p8key = "P8 Key"
    case p8FileExt = "p8"
    case importP8File = "Import P8"
    case clearIfExist = "Clear If Exist"
    case saveAsPreset = "Save As Preset"
    case payload = "Payload"
    case loadTemplate = "Load Template (⌘+T)"
    case loadTemplateShortcutKey = "T"
    case sending = "Sending..."
    case send = "Send (⌘+⏎)"
    case sendPush = "Send Push"
    case log = "Log"
    
    case appInfo = "App Info"
    case fillInAppInfo = "Fill this App's Info"
    case clearCurrentAppInfo = "Clear Current App Info"
    case removeAppInfoFromPreset = "Remove App Info From Preset Config"
    case saveAppInfoAsPreset = "Save App Info As Preset Config"
    case loadTemplatePayload = "Load Template Payload"
    case clearPayload = "Clear Payload"
    case tipForNotReady = "The App Info is not ready for send push!"
    
    var value: String {
        self.rawValue
    }
    
    var firstChar: Character {
        let i = self.value.index(self.value.startIndex, offsetBy: 0)
        let char = self.value[i]
        return char
    }
}

//
//  Config+Preset.swift
//  APNs Helper
//
//  Created by joker on 2022/9/29.
//

import Foundation

extension Config {
    
    static let invalid = Config(
        deviceToken: "",
        pushKitDeviceToken: "",
        fileProviderDeviceToken: "",
        appBundleID: "",
        privateKey: "",
        keyIdentifier: "",
        teamIdentifier: "")
    
    static let f101 = Config(
        deviceToken: "85acd4ca201adc6563263bf692032c4916e61d5f911d0fac1c0b52ab5c11bac8",
        pushKitDeviceToken: "",
        fileProviderDeviceToken: "",
        appBundleID: "com.f101.client",
        privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg2iKVgB74ZuopMy5O
    j9bereVYOMeIyvnAx7KHAfgx1nKhRANCAAQ6JUvJJ6rR8rEjsqaQsA2FHaV2Vrk1
    CPqN4zQAHvKtCxvWbtCepW9lF3/BdF4w0YQSX+pNAw9vNqV6tYTbef6s
    -----END PRIVATE KEY-----
    """,
        keyIdentifier: "4CGRY5A64Y",
        teamIdentifier: "7HSS6X2323")
    
    
    static let f101InHouse = Config(
        deviceToken: "",
        pushKitDeviceToken: "",
        fileProviderDeviceToken: "",
        appBundleID: "com.bytedance.fpb",
        privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgiSVQEsgDQbJwN199
    igNEMRBe7OhNqF3mSSubOaoLbhqhRANCAASWD1oZ9psqe0gM+V9OZ40idgtWfpgx
    mfY7ps8dM71zVPFQD0mERAnueq83h2YWh8yixBnpfN5q2Yc1a0OHTlQX
    -----END PRIVATE KEY-----
    """,
        keyIdentifier: "Y9ZXMM22L8",
        teamIdentifier: "X46375UBYG")
    
    static let f100 = Config(
        deviceToken: "",
        pushKitDeviceToken: "",
        fileProviderDeviceToken: "",
        appBundleID: "com.f100.client",
        privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg2iKVgB74ZuopMy5O
    j9bereVYOMeIyvnAx7KHAfgx1nKhRANCAAQ6JUvJJ6rR8rEjsqaQsA2FHaV2Vrk1
    CPqN4zQAHvKtCxvWbtCepW9lF3/BdF4w0YQSX+pNAw9vNqV6tYTbef6s
    -----END PRIVATE KEY-----
    """,
        keyIdentifier: "4CGRY5A64Y",
        teamIdentifier: "7HSS6X2323")
    
    
    static let f100InHouse = Config(
        deviceToken: "",
        pushKitDeviceToken: "",
        fileProviderDeviceToken: "",
        appBundleID: "com.bytedance.fp1",
        privateKey: """
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgiSVQEsgDQbJwN199
    igNEMRBe7OhNqF3mSSubOaoLbhqhRANCAASWD1oZ9psqe0gM+V9OZ40idgtWfpgx
    mfY7ps8dM71zVPFQD0mERAnueq83h2YWh8yixBnpfN5q2Yc1a0OHTlQX
    -----END PRIVATE KEY-----
    """,
        keyIdentifier: "Y9ZXMM22L8",
        teamIdentifier: "X46375UBYG")
    
}

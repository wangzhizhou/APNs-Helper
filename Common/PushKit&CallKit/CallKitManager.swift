//
//  CallKitManager.swift
//  APNs Helper
//
//  Created by joker on 2023/4/12.
//
#if ENABLE_PUSHKIT && os(iOS)

import CallKit

class CallKitManager: NSObject {

    // MARK: 单例实现
    @MainActor static let shared = CallKitManager()
    private override init() {}

    // MARK: 功能实现
    private(set) lazy var callProvider: CXProvider = {
        var config = CXProviderConfiguration()
        config.supportsVideo = false
        config.supportedHandleTypes = [CXHandle.HandleType.generic]
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.includesCallsInRecents = false
        let provider = CXProvider(configuration: config)
        return provider
    }()

    func setupForVoip() {
        callProvider.setDelegate(self, queue: .main)
        let updateHandle = CXHandle(type: .generic, value: "VoIP Push")
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = updateHandle
        callProvider.reportNewIncomingCall(with: UUID(), update: callUpdate) { _ in }
    }
}

extension CallKitManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {

    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()

        let endCallAction = CXEndCallAction(call: action.callUUID)
        let transaction = CXTransaction(action: endCallAction)
        CXCallController().request(transaction) { _ in }
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        action.fulfill()
    }
}

#endif

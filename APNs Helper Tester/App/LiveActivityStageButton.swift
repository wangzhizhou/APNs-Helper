//
//  LiveActivityStageButton.swift
//  APNs Helper Tester
//
//  Created by joker on 2023/11/7.
//

import SwiftUI

#if canImport(ActivityKit)
import ActivityKit

struct LiveActivityStageButton: View {
    
    @EnvironmentObject var model: TesterAppModel
    
    var body: some View {
        
        HStack {
            let disable = model.appInfo.liveActivityPushToken.isEmpty && model.stage != .start
            
            Button("\(model.stage.rawValue) live activity") {
                switch model.stage {
                case .start:
                    startLiveActivity()
                    model.stage = .update
                case .update:
                    updateLiveActivity()
                    model.stage = .end
                case .end:
                    endLiveActivity()
                    model.stage = .dismiss
                case .dismiss:
                    dismissLiveActivity()
                    model.stage = .start
                }
            }
            .disabled(disable)
            
            Spacer()
            
            if disable {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    private func startLiveActivity() {
        model.liveActivity = try? Activity.request(
            attributes: LiveActivityAttributes(),
            content: ActivityContent(
                state: LiveActivityContentState(),
                staleDate: .none
            ),
            pushType: .token
        )
    }
    
    private func updateLiveActivity() {
        Task {
            await model.liveActivity?.update(
                ActivityContent(
                    state: LiveActivityContentState(),
                    staleDate: .none
                )
            )
        }
    }
    
    private func endLiveActivity() {
        Task {
            await model.liveActivity?.end(
                ActivityContent(
                    state: LiveActivityContentState(),
                    staleDate: nil
                )
            )
        }
    }
    
    private func dismissLiveActivity() {
        Task {
            await model.liveActivity?.end(
                ActivityContent(
                    state: LiveActivityContentState(),
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
        }
    }
}

#Preview {
    LiveActivityStageButton()
}

#endif

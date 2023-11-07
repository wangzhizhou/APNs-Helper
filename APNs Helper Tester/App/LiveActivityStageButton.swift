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
    
    @State private var stage: LiveActivityContentState.LiveActivityStage = .none
    
    var body: some View {
        Button {
            switch stage {
            case .none:
                stage = .new
                startLiveActivity()
            case .new:
                stage = .update
                updateLiveActivity()
            case .update:
                stage = .end
                endLiveActivity()
            case .end:
                stage = .none
                dismissLiveActivity()
            }
        } label: {
            HStack {
                Text("Live Activity Operation")
                
                Spacer()
                
                Text("\(stage.rawValue)")
            }
        }
    }
    
    private func startLiveActivity() {
        model.liveActivity = try? Activity.request(
            attributes: LiveActivityAttributes(),
            content: ActivityContent(
                state: LiveActivityContentState(stage: .new),
                staleDate: .none
            ),
            pushType: .token
        )
    }
    
    private func updateLiveActivity() {
        Task {
            await model.liveActivity?.update(
                ActivityContent(
                    state: LiveActivityContentState(stage: .update),
                    staleDate: .none
                )
            )
        }
    }
    
    private func endLiveActivity() {
        Task {
            await model.liveActivity?.end(
                ActivityContent(
                    state: LiveActivityContentState(stage: .end),
                    staleDate: nil
                )
            )
        }
    }
    
    private func dismissLiveActivity() {
        Task {
            await model.liveActivity?.end(
                ActivityContent(
                    state: LiveActivityContentState(stage: .end),
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
            model.liveActivity = nil
        }
    }
}

#Preview {
    LiveActivityStageButton()
}

#endif

//
//  OptionsView.swift
//  WatchIron Extension
//
//  Created by Karim Abou Zeid on 11.11.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var workoutSessionManagerStore: WorkoutSessionManagerStore
    
    var body: some View {
        VStack {
            Button(action: {
                guard let start = self.workoutSessionManagerStore.workoutSessionManager?.startDate else { return }
                guard let uuid = self.workoutSessionManagerStore.workoutSessionManager?.uuid else { return }
                let end = self.workoutSessionManagerStore.workoutSessionManager?.endDate ?? Date()
                self.workoutSessionManagerStore.endWorkoutSession(start: start, end: end, title: nil, uuid: uuid)
            }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("完成追踪")
                }
            }
            
            Button(action: {
                if let uuid = self.workoutSessionManagerStore.workoutSessionManager?.uuid {
                    self.workoutSessionManagerStore.discardWorkoutSession(uuid: uuid)
                } else {
                    self.workoutSessionManagerStore.discardWorkoutSession()
                }
            }) {
                HStack {
                    Image(systemName: "xmark")
                    Text("取消追踪")
                }
                .foregroundColor(.red)
            }
            
            Text("仅在出现问题时使用。")
                .font(.system(.caption2))
        }
    }
}

//
//  HealthSettingsView.swift
//  Iron
//
//  Created by Karim Abou Zeid on 31.10.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI
import WorkoutDataKit

struct HealthSettingsView: View {
    @EnvironmentObject var exerciseStore: ExerciseStore
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var updating = false
    @State private var updateResult: IdentifiableHolder<Result<HealthManager.WorkoutUpdates, Error>>?
    
    func updateResultAlert(updateResult: Result<HealthManager.WorkoutUpdates, Error>) -> Alert {
        switch updateResult {
        case .success(let updates):
            return Alert(
                title: Text("成功更新了 Apple 健康中的训练记录"),
                message: Text("创建了 \(updates.created) 个训练记录，删除了 \(updates.deleted) 个训练记录，修改了 \(updates.modified) 个训练记录。")
            )
        case .failure(let error):
            return Alert(title: Text("更新 Apple 健康训练记录失败"), message: Text(error.localizedDescription))
        }
    }
    
    var body: some View {
        Form {
            Section(footer: Text("将缺失的训练记录添加到 Apple 健康，并从 Apple 健康中删除 Iron 中不再存在的训练记录。这也会更新开始或结束时间已修改的训练记录。")) {
                Button("更新 Apple 健康训练记录") {
                    self.updating = true
                    HealthManager.shared.updateHealthWorkouts(managedObjectContext: self.managedObjectContext, exerciseStore: self.exerciseStore) { result in
                        DispatchQueue.main.async {
                            self.updateResult = IdentifiableHolder(value: result)
                            self.updating = false
                        }
                    }
                }
                .disabled(updating) // wait for updating to finish before allowing to tap again
            }
        }
        .navigationBarTitle("Apple 健康", displayMode: .inline)
        .alert(item: $updateResult) { updateResultHolder in
            self.updateResultAlert(updateResult: updateResultHolder.value)
        }
    }
}

import HealthKit
extension HealthSettingsView {
    static var isSupported: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
}

struct HealthSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        HealthSettingsView()
    }
}

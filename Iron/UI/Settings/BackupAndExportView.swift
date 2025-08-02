//
//  BackupAndExportView.swift
//  Iron
//
//  Created by Karim Abou Zeid on 17.09.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI
import CoreData
import WorkoutDataKit
import os.log

struct BackupAndExportView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var exerciseStore: ExerciseStore
    
    @ObservedObject var backupStore = BackupFileStore.shared
    
    @State private var showExportWorkoutDataSheet = false
    
    @State private var backupError: BackupError?
    private struct BackupError: Identifiable {
         let id = UUID()
         let error: Error?
    }
    
    @State private var activityItems: [Any]?
     
    private func alert(backupError: BackupError) -> Alert {
        let errorMessage = backupError.error?.localizedDescription
        let text = errorMessage.map { Text($0) }
        return Alert(title: Text("无法创建备份"), message: text)
    }
    
    private var cloudBackupFooter: some View {
        var strings = [String]()
        if settingsStore.autoBackup {
            strings.append("每次退出应用时会自动创建备份。")
        }
        strings.append("备份存储在您的私人 iCloud Drive 中。只保留每天的最后一个备份。您也可以通过内置的文件应用访问备份文件。")
        if let creationDate = backupStore.lastBackup?.creationDate {
            strings.append("最后备份时间：" + BackupFileStore.BackupFile.dateFormatter.string(from: creationDate))
        }
        
        return Text(strings.joined(separator: "\n"))
    }
    
    var body: some View {
        Form {
            Section(header: Text("导出".uppercased())) {
                Button("训练数据") {
                    self.showExportWorkoutDataSheet = true
                }
                Button("备份") {
                    do {
                        os_log("Creating backup data", log: .backup, type: .default)
                        let data = try IronBackup.createBackupData(managedObjectContext: self.managedObjectContext, exerciseStore: self.exerciseStore)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let url = try self.tempFile(data: data, name: "\(formatter.string(from: Date())).ironbackup")
                        
                        self.shareFile(url: url)
                    } catch {
                        os_log("Could not create backup: %@", log: .backup, type: .default, error.localizedDescription)
                        self.backupError = BackupError(error: error)
                    }
                }
            }
            
            Section(header: Text("iCloud 备份".uppercased()), footer: cloudBackupFooter) {
                NavigationLink(destination: RestoreBackupView(backupStore: backupStore)) {
                    Text("恢复")
                }
                Toggle("自动备份", isOn: $settingsStore.autoBackup)
                Button("立即备份") {
                    self.backupStore.create(data: {
                        return try self.managedObjectContext.performAndWait { context in
                            os_log("Creating backup data", log: .backup, type: .default)
                            return try IronBackup.createBackupData(managedObjectContext: context, exerciseStore: self.exerciseStore)
                        }
                    }, onError: { error in
                        self.backupError = BackupError(error: error)
                    })
                }
            }
        }
        .onAppear(perform: backupStore.fetchBackups)
        .navigationBarTitle("备份与导出", displayMode: .inline)
        .actionSheet(isPresented: $showExportWorkoutDataSheet) {
            ActionSheet(title: Text("训练数据"), buttons: [
                .default(Text("JSON"), action: {
                    guard let workouts = self.fetchWorkouts() else { return }
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
                    encoder.dateEncodingStrategy = .iso8601
                    if let exercisesKey = CodingUserInfoKey.exercisesKey {
                        encoder.userInfo[exercisesKey] = ExerciseStore.shared.exercises
                    }
                    
                    guard let data = try? encoder.encode(workouts) else { return }
                    guard let url = try? self.tempFile(data: data, name: "workout_data.json") else { return }
                    self.shareFile(url: url)
                }),
                .default(Text("TXT"), action: {
                    guard let workouts = self.fetchWorkouts() else { return }
                    
                    let text = workouts.compactMap { $0.logText(in: self.exerciseStore.exercises, weightUnit: self.settingsStore.weightUnit) }.joined(separator: "\n\n\n\n\n")
                    
                    guard let data = text.data(using: .utf8) else { return }
                    guard let url = try? self.tempFile(data: data, name: "workout_data.txt") else { return }
                    self.shareFile(url: url)
                }),
                .cancel()
            ])
        }
        .alert(item: $backupError) { backupError in
            self.alert(backupError: backupError)
        }
        .overlay(ActivitySheet(activityItems: $activityItems))
    }
    
    private func fetchWorkouts() -> [Workout]? {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Workout.isCurrentWorkout)) != %@", NSNumber(booleanLiteral: true))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.start, ascending: false)]
        return (try? self.managedObjectContext.fetch(request))
    }
    
    private func tempFile(data: Data, name: String) throws -> URL {
        let path = FileManager.default.temporaryDirectory
        let url = path.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        return url
    }
    
    private func shareFile(url: URL) {
        self.activityItems = [url]
    }
}

#if DEBUG
struct BackupAndExportView_Previews: PreviewProvider {
    static var previews: some View {
        BackupAndExportView()
            .mockEnvironment(weightUnit: .metric)
    }
}
#endif

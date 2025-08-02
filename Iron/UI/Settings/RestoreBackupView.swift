//
//  RestoreBackupView.swift
//  Iron
//
//  Created by Karim Abou Zeid on 28.10.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI
import WorkoutDataKit

struct RestoreBackupView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var exerciseStore: ExerciseStore
    
    @ObservedObject var backupStore: BackupFileStore
    
    @State private var restoreResult: IdentifiableHolder<Result<Void, Error>>?
    @State private var restoreBackupUrl: IdentifiableHolder<URL>?
    
    var body: some View {
        List {
            Section(header: Text("备份".uppercased()), footer: Text("点击备份即可恢复。")) {
                ForEach(backupStore.backups) { backup in
                    Button(action: {
                        self.restoreBackupUrl = IdentifiableHolder(value: backup.url)
                    }) {
                        VStack(alignment: .leading) {
                            Text(BackupFileStore.BackupFile.dateFormatter.string(from: backup.creationDate))
                                .foregroundColor(.primary)
                            Text("\(backup.deviceName) • \(BackupFileStore.BackupFile.byteCountFormatter.string(fromByteCount: Int64(backup.fileSize)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        self.backupStore.delete(at: index)
                    }
                }
                
                // TODO: remove this once the .placeholder() works
                if backupStore.backups.isEmpty {
                    Button("空") {}
                        .disabled(true)
                }
            }
        }
        .listStyleCompat_InsetGroupedListStyle()
        .onAppear(perform: backupStore.fetchBackups)
        .navigationBarItems(trailing: EditButton())
        .actionSheet(item: $restoreBackupUrl) { urlHolder in
            RestoreActionSheet.create(context: self.managedObjectContext, exerciseStore: self.exerciseStore, data: { try Data(contentsOf: urlHolder.value) }) { result in
                self.restoreResult = IdentifiableHolder(value: result)
            }
        }
        .alert(item: $restoreResult) { restoreResultHolder in
            RestoreActionSheet.restoreResultAlert(restoreResult: restoreResultHolder.value)
        }
        .navigationBarTitle("恢复备份", displayMode: .inline)
    }
}

import CoreData
enum RestoreActionSheet {
    typealias RestoreResult = Result<Void, Error>
    
    static func create(context: NSManagedObjectContext, exerciseStore: ExerciseStore, data: @escaping () throws -> Data, completion: @escaping (RestoreResult) -> Void) -> ActionSheet {
        ActionSheet(
            title: Text("恢复备份"),
            message: Text("此操作无法撤销。您的所有训练和自定义动作将被备份中的内容替换。您的设置不受影响。"),
            buttons: [
                .destructive(Text("恢复"), action: {
                    do {
                        try IronBackup.restoreBackupData(data: data(), managedObjectContext: context, exerciseStore: exerciseStore)
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }),
                .cancel()
            ]
        )
    }
    
    static func restoreResultAlert(restoreResult: RestoreResult) -> Alert {
        switch restoreResult {
        case .success():
            return Alert(title: Text("恢复成功"))
        case .failure(let error):
            let errorMessage: String
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case let .dataCorrupted(context):
                    errorMessage = "数据损坏。\(context.debugDescription)"
                case let .keyNotFound(_, context):
                    errorMessage = "找不到键。\(context.debugDescription)"
                case let .typeMismatch(_, context):
                    errorMessage = "类型不匹配。\(context.debugDescription)"
                case let .valueNotFound(_, context):
                    errorMessage = "找不到值。\(context.debugDescription)"
                @unknown default:
                    errorMessage = "解码错误。\(error.localizedDescription)"
                }
            } else {
                errorMessage = error.localizedDescription
            }
            return Alert(title: Text("恢复失败"), message: Text(errorMessage))
        }
    }
}

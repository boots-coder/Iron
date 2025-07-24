import SwiftUI
import CoreData
import WorkoutDataKit

struct HistoryView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var exerciseStore: ExerciseStore
    @EnvironmentObject var sceneState: SceneState
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(fetchRequest: HistoryView.fetchRequest) var workouts

    static var fetchRequest: NSFetchRequest<Workout> {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Workout.isCurrentWorkout)) != %@", NSNumber(booleanLiteral: true))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.start, ascending: false)]
        return request
    }
    
    @State private var activityItems: [Any]?
    @State private var offsetsToDelete: IndexSet?
    
    /// Returns `true` if at least one workout has workout exercises
    private func needsConfirmBeforeDelete(offsets: IndexSet) -> Bool {
        for index in offsets {
            if workouts[index].workoutExercises?.count ?? 0 != 0 {
                return true
            }
        }
        return false
    }
    
    private func deleteAt(offsets: IndexSet) {
        let workouts = self.workouts
        for i in offsets.sorted().reversed() {
            workouts[i].deleteOrCrash()
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)
                        .environmentObject(self.settingsStore)
                    ) {
                        WorkoutCell(workout: workout)
                            .contextMenu {
                                // TODO: Add images when SwiftUI fixes the image size
                                if UIDevice.current.userInterfaceIdiom != .pad {
                                    // Not working on iPad, last checked iOS 13.4
                                    Button("分享") { // 替换 "Share"
                                        guard let logText = workout.logText(in: self.exerciseStore.exercises, weightUnit: self.settingsStore.weightUnit) else { return }
                                        self.activityItems = [logText]
                                    }
                                }
                                Button("重复此训练") { // 替换 "Repeat"
                                    WorkoutDetailView.repeatWorkout(workout: workout, settingsStore: self.settingsStore, sceneState: sceneState)
                                }
                                Button("重复（空白）") { // 替换 "Repeat (Blank)"
                                    WorkoutDetailView.repeatWorkoutBlank(workout: workout, settingsStore: self.settingsStore, sceneState: sceneState)
                                }
                        }
                    }
                }
                .onDelete { offsets in
                    if self.needsConfirmBeforeDelete(offsets: offsets) {
                        self.offsetsToDelete = offsets
                    } else {
                        self.deleteAt(offsets: offsets)
                    }
                }
            }
            .listStyleCompat_InsetGroupedListStyle()
            .navigationBarItems(trailing: EditButton())
            .actionSheet(item: $offsetsToDelete) { offsets in
                ActionSheet(title: Text("此操作无法撤销。"), // 替换 "This cannot be undone."
                            buttons: [
                                .destructive(Text("删除训练记录"), action: { // 替换 "Delete Workout"
                                    self.deleteAt(offsets: offsets)
                                }),
                                .cancel(Text("取消")) // 替换 "Cancel"
                            ])
            }
            .placeholder(show: workouts.isEmpty,
                         Text("您完成的训练记录会显示在这里。") // 替换 "Your finished workouts will appear here."
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
            )
            .navigationBarTitle(Text("历史记录")) // 替换 "History"
            
            // Placeholder for iPad or empty state
            Text("未选择任何训练记录") // 替换 "No workout selected"
                .foregroundColor(.secondary)
        }
        .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0) // Hack to show the master view on iPad in portrait mode
        .overlay(ActivitySheet(activityItems: self.$activityItems))
    }
}

private struct WorkoutCell: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var exerciseStore: ExerciseStore
    @ObservedObject var workout: Workout

    private var durationString: String? {
        guard let duration = workout.duration else { return nil }
        return Workout.durationFormatter.string(from: duration)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workout.displayTitle(in: self.exerciseStore.exercises))
                    .font(.body)
                
                Text(Workout.dateFormatter.string(from: workout.start, fallback: "未知日期")) // 替换 "Unknown date"
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                workout.comment.map {
                    Text($0.enquoted)
                        .lineLimit(1)
                        .font(Font.caption.italic())
                        .foregroundColor(.secondary)
                }
            }
            .layoutPriority(1)
            
            Spacer()
            
            durationString.map {
                Text($0)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder()
                            .foregroundColor(Color(.systemFill))
                    )
            }
            
            workout.muscleGroupImage(in: self.exerciseStore.exercises)
        }
    }
}

#if DEBUG
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .mockEnvironment(weightUnit: .metric)
    }
}
#endif

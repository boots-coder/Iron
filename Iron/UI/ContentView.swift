import SwiftUI
import WorkoutDataKit

let NAVIGATION_BAR_SPACING: CGFloat = 16

struct ContentView : View {
    @EnvironmentObject private var sceneState: SceneState
    
    @State private var restoreResult: IdentifiableHolder<Result<Void, Error>>?
    @State private var restoreBackupData: IdentifiableHolder<Data>?
    
    var body: some View {
        tabView
            .edgesIgnoringSafeArea([.top, .bottom])
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.RestoreFromBackup)) { output in
                guard let backupData = output.userInfo?[restoreFromBackupDataUserInfoKey] as? Data else { return }
                self.restoreBackupData = IdentifiableHolder(value: backupData)
            }
            .overlay(
                Color.clear.frame(width: 0, height: 0)
                    .actionSheet(item: $restoreBackupData) { restoreBackupDataHolder in
                        RestoreActionSheet.create(context: WorkoutDataStorage.shared.persistentContainer.viewContext, exerciseStore: ExerciseStore.shared, data: { restoreBackupDataHolder.value }) { result in
                            self.restoreResult = IdentifiableHolder(value: result)
                        }
                    }
            )
            .alert(item: $restoreResult) { restoreResultHolder in
                RestoreActionSheet.restoreResultAlert(restoreResult: restoreResultHolder.value)
            }
    }
    
    @ViewBuilder
    private var tabView: some View {
        if #available(iOS 14, *) {
            TabView(selection: $sceneState.selectedTabNumber) {
                FeedView()
                    .tag(SceneState.Tab.feed.rawValue)
                    .tabItem {
                        Label("动态", systemImage: "house") // 替换 "Feed" 为 "动态"
                    }

                HistoryView()
                    .tag(SceneState.Tab.history.rawValue)
                    .tabItem {
                        Label("历史记录", systemImage: "clock") // 替换 "History" 为 "历史记录"
                    }

                WorkoutTab()
                    .tag(SceneState.Tab.workout.rawValue)
                    .tabItem {
                        Label("训练", systemImage: "plus.diamond") // 替换 "Workout" 为 "训练"
                    }

                ExerciseMuscleGroupsView()
                    .tag(SceneState.Tab.exercises.rawValue)
                    .tabItem {
                        Label("动作分类", systemImage: "tray.full") // 替换 "Exercises" 为 "动作分类"
                    }

                SettingsView()
                    .tag(SceneState.Tab.settings.rawValue)
                    .tabItem {
                        Label("设置", systemImage: "gear") // 替换 "Settings" 为 "设置"
                    }
            }
            .productionEnvironment()
        } else {
            UITabView(viewControllers: [
                FeedView()
                    .productionEnvironment()
                    .hostingController()
                    .tabItem(title: "动态", image: UIImage(systemName: "house"), tag: 0), // 替换 "Feed" 为 "动态"

                HistoryView()
                    .productionEnvironment()
                    .hostingController()
                    .tabItem(title: "历史记录", image: UIImage(systemName: "clock"), tag: 1), // 替换 "History" 为 "历史记录"

                WorkoutTab()
                    .productionEnvironment()
                    .hostingController()
                    .tabItem(title: "训练", image: UIImage(systemName: "plus.square"), tag: 2), // 替换 "Workout" 为 "训练"

                ExerciseMuscleGroupsView()
                    .productionEnvironment()
                    .hostingController()
                    .tabItem(title: "动作分类", image: UIImage(systemName: "tray.full"), tag: 3), // 替换 "Exercises" 为 "动作分类"

                SettingsView()
                    .productionEnvironment()
                    .hostingController()
                    .tabItem(title: "设置", image: UIImage(systemName: "gear"), tag: 4), // 替换 "Settings" 为 "设置"
            ], selection: sceneState.selectedTabNumber)
        }
    }
}

private extension View {
    func productionEnvironment() -> some View {
        self
            .environmentObject(SettingsStore.shared)
            .environmentObject(RestTimerStore.shared)
            .environmentObject(ExerciseStore.shared)
            .environment(\.managedObjectContext, WorkoutDataStorage.shared.persistentContainer.viewContext)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
            .mockEnvironment(weightUnit: .metric)
    }
}
#endif

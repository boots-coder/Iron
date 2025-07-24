import SwiftUI
import WorkoutDataKit

struct ExerciseMuscleGroupsView : View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var exerciseStore: ExerciseStore
    
    // select the all exercises tab by default on iPad
    @State private var allExercisesSelected = UIDevice.current.userInterfaceIdiom == .pad ? true : false
    
    func exerciseGroupCell(exercises: [Exercise]) -> some View {
        let muscleGroup = exercises.first?.muscleGroup ?? "未分类"
        return NavigationLink(destination:
            ExercisesView(exercises: exercises)
                .navigationBarTitle(Text(muscleGroup), displayMode: .inline)
        ) {
            HStack {
                Text(muscleGroup) // 显示中文肌肉分组名
                Spacer()
                Text("(\(exercises.count) 个动作)") // 动作数量
                    .foregroundColor(.secondary)
                Exercise.imageFor(muscleGroup: muscleGroup)
                    .foregroundColor(Exercise.colorFor(muscleGroup: muscleGroup))
            }
        }
    }
    
    private var exerciseGroups: [ExerciseGroup] {
        ExerciseStore.splitIntoMuscleGroups(exercises: exerciseStore.shownExercises)
    }
    
    var body: some View {
        NavigationView {
            List {
                // 第一部分：所有动作
                Section {
                    NavigationLink(destination: AllExercisesView(exerciseGroups: exerciseGroups), isActive: $allExercisesSelected) {
                        HStack {
                            Text("全部动作") // 替换 "All"
                            Spacer()
                            Text("(\(exerciseStore.shownExercises.count) 个动作)") // 动作总数
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 第二部分：按肌肉分组
                Section {
                    ForEach(exerciseGroups) { exerciseGroup in
                        self.exerciseGroupCell(exercises: exerciseGroup.exercises)
                    }
                }
                
                // 第三部分：自定义动作和隐藏动作
                Section {
                    NavigationLink(destination:
                        CustomExercisesView()
                            .navigationBarTitle(Text("自定义动作"), displayMode: .inline) // 替换 "Custom"
                    ) {
                        HStack {
                            Text("自定义动作") // 替换 "Custom"
                            Spacer()
                            Text("(\(exerciseStore.customExercises.count) 个动作)") // 自定义动作数量
                                .foregroundColor(.secondary)
                        }
                    }

                    if !exerciseStore.hiddenExercises.isEmpty {
                        NavigationLink(destination:
                            ExercisesView(exercises: exerciseStore.hiddenExercises)
                                .navigationBarTitle(Text("隐藏动作"), displayMode: .inline) // 替换 "Hidden"
                        ) {
                            HStack {
                                Text("隐藏动作") // 替换 "Hidden"
                                Spacer()
                                Text("(\(exerciseStore.hiddenExercises.count) 个动作)") // 隐藏动作数量
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyleCompat_InsetGroupedListStyle()
            .navigationBarTitle("动作分类") // 替换 "Exercises"
        }
        .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0) // hack that makes the master view show on iPad on portrait mode
    }
}

private struct AllExercisesView: View {
    @ObservedObject private var filter: ExerciseGroupFilter
    
    init(exerciseGroups: [ExerciseGroup]) {
        self.filter = ExerciseGroupFilter(exerciseGroups: exerciseGroups)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("搜索", text: $filter.filter) // 替换 "Search"
                .textFieldStyle(SearchTextFieldStyle(text: $filter.filter))
                .padding()
            
            Divider()
            
            MuscleGroupSectionedExercisesView(exerciseGroups: filter.exerciseGroups)
        }
        .navigationBarTitle(Text("全部动作"), displayMode: .inline) // 替换 "All Exercises"
    }
}

#if DEBUG
struct ExerciseCategoryView_Previews : PreviewProvider {
    static var previews: some View {
        ExerciseMuscleGroupsView()
            .mockEnvironment(weightUnit: .metric)
    }
}
#endif

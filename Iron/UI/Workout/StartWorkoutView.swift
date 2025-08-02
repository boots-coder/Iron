//
//  StartWorkoutView.swift
//  Sunrise Fit
//
//  Created by Karim Abou Zeid on 19.07.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI
import CoreData
import WorkoutDataKit
import os.log

struct StartWorkoutView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var quote = Quotes.quotes.randomElement()
    
    @State private var offsetsToDelete: IndexSet?
    
    @FetchRequest(fetchRequest: StartWorkoutView.fetchRequest) var workoutPlans

    static var fetchRequest: NSFetchRequest<WorkoutPlan> {
        let request: NSFetchRequest<WorkoutPlan> = WorkoutPlan.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutPlan.title, ascending: false)]
        return request
    }
    
    var body: some View {
        NavigationView {
            List {
                if #available(iOS 15.0, *) {
                    Button {
                        Workout.create(context: self.managedObjectContext).startOrCrash()
                    } label: {
                        HStack {
                            Spacer()
                            Text("开始训练").font(.headline)
                            Spacer()
                        }
                        .padding(6)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        Workout.create(context: self.managedObjectContext).startOrCrash()
                    } label: {
                        HStack {
                            Spacer()
                            Text("开始训练").font(.headline)
                            Spacer()
                        }
                        .padding(6)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                ForEach(workoutPlans) { workoutPlan in
                    Section {
                        WorkoutPlanCell(workoutPlan: workoutPlan)
                        WorkoutPlanRoutines(workoutPlan: workoutPlan)
                            .deleteDisabled(true)
                    }
                }
                .onDelete { offsets in
                    if self.needsConfirmBeforeDelete(offsets: offsets) {
                        self.offsetsToDelete = offsets
                    } else {
                        self.deleteAt(offsets: offsets)
                    }
                }
                
                Section {
                    Button(action: {
                        self.newWorkoutPlan()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("制定新的计划")
                        }
                    }
                }
            }
            .listStyleCompat_InsetGroupedListStyle()
            .navigationBarTitle("训练")
            .actionSheet(item: $offsetsToDelete) { offsets in
                ActionSheet(title: Text("删除计划"), buttons: [
                    .destructive(Text("删除该训练计划"), action: {
                        self.deleteAt(offsets: offsets)
                    }),
                    .cancel()
                ])
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func newWorkoutPlan() {
        _ = WorkoutPlan.create(context: managedObjectContext)
        managedObjectContext.saveOrCrash()
    }
    
    /// Resturns `true` if at least one workout plan has workout routines
    private func needsConfirmBeforeDelete(offsets: IndexSet) -> Bool {
        for index in offsets {
            if workoutPlans[index].workoutRoutines?.count ?? 0 != 0 {
                return true
            }
        }
        return false
    }
    
    private func deleteAt(offsets: IndexSet) {
        let workoutPlans = self.workoutPlans
        for i in offsets {
            self.managedObjectContext.delete(workoutPlans[i])
        }
        self.managedObjectContext.saveOrCrash()
    }
}

private struct WorkoutPlanCell: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var workoutPlan: WorkoutPlan
    
    var body: some View {
        NavigationLink(destination: WorkoutPlanView(workoutPlan: workoutPlan)) {
            VStack(alignment: .leading) {
                Text(workoutPlan.displayTitle).font(.headline)
            }
            .contextMenu {
                Button(action: {
                    _ = self.workoutPlan.duplicate(context: self.managedObjectContext)
                    self.managedObjectContext.saveOrCrash()
                }) {
                    Text("复制")
                    Image(systemName: "doc.on.doc")
                }
                Button(action: {
                    self.managedObjectContext.delete(self.workoutPlan)
                    self.managedObjectContext.saveOrCrash()
                }) {
                    Text("删除")
                    Image(systemName: "trash")
                }
            }
        }
    }
}

private struct WorkoutPlanRoutines: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var exerciseStore: ExerciseStore
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var workoutPlan: WorkoutPlan
    
    private var workoutRoutines: [WorkoutRoutine] {
        workoutPlan.workoutRoutines?.array as? [WorkoutRoutine] ?? []
    }
    
    var body: some View {
        ForEach(workoutRoutines) { workoutRoutine in
            Button(action: {
                workoutRoutine.createWorkout(context: self.managedObjectContext).startOrCrash()
            }) {
                VStack(alignment: .leading) {
                    Text(workoutRoutine.displayTitle).italic()
                    Text(workoutRoutine.subtitle(in: self.exerciseStore.exercises))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}

#if DEBUG
struct StartWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StartWorkoutView()
            
            StartWorkoutView()
                .environment(\.colorScheme, .dark)
            
            StartWorkoutView()
                .previewDevice(.init("iPhone SE"))
            
            StartWorkoutView()
                .previewDevice(.init("iPhone 11 Pro Max"))
        }
        .mockEnvironment(weightUnit: .metric)
    }
}
#endif

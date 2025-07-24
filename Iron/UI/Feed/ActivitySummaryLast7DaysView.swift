//
//  ActivitySummaryLast7DaysView.swift
//  Iron
//
//  Created by Karim Abou Zeid on 08.10.20.
//  Copyright © 2020 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI
import CoreData
import WorkoutDataKit

struct ActivitySummaryLast7DaysView: View {
    @Environment(\.calendar) var calendar
    
    @EnvironmentObject var settingsStore: SettingsStore
    
    @FetchRequest(fetchRequest: Workout.fetchRequest()) var workoutsFromSevenDaysAgo // overwritten in init()
    @FetchRequest(fetchRequest: Workout.fetchRequest()) var workoutsFromFourteenDaysAgo // overwritten in init()
    
    private static func sevenDaysFetchRequest(sevenDaysAgo: Date) -> NSFetchRequest<Workout> {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Workout.isCurrentWorkout)) != %@ AND \(#keyPath(Workout.start)) >= %@", NSNumber(booleanLiteral: true), sevenDaysAgo as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.start, ascending: false)]
        return request
    }
    
    private static func fourteenDaysFetchRequest(sevenDaysAgo: Date, fourteenDaysAgo: Date) -> NSFetchRequest<Workout> {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Workout.isCurrentWorkout)) != %@ AND \(#keyPath(Workout.start)) >= %@ AND \(#keyPath(Workout.start)) < %@", NSNumber(booleanLiteral: true), fourteenDaysAgo as NSDate, sevenDaysAgo as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.start, ascending: false)]
        return request
    }
    
    init() {
        let now = Date()
        self._workoutsFromSevenDaysAgo = FetchRequest(fetchRequest: Self.sevenDaysFetchRequest(sevenDaysAgo: calendar.date(byAdding: .day, value: -7, to: now)!))
        self._workoutsFromFourteenDaysAgo = FetchRequest(fetchRequest: Self.fourteenDaysFetchRequest(sevenDaysAgo: calendar.date(byAdding: .day, value: -7, to: now)!, fourteenDaysAgo: calendar.date(byAdding: .day, value: -14, to: now)!))
    }
    
    var totalTime: (duration: TimeInterval, difference: Double) {
        let totalTimeSevenDaysAgo = workoutsFromSevenDaysAgo.map { $0.safeDuration }.reduce(0, +)
        let totalTimeFourteenDaysAgo = workoutsFromFourteenDaysAgo.map { $0.safeDuration }.reduce(0, +)
        
        var durationPercent = totalTimeSevenDaysAgo == 0 ? 0 : (totalTimeSevenDaysAgo / totalTimeFourteenDaysAgo) - 1
        durationPercent = abs(durationPercent) < 0.001 ? 0 : durationPercent
        
        return (totalTimeSevenDaysAgo, durationPercent)
    }
    
    var totalWeight: (weight: Double, difference: Double) {
        let totalWeightSevenDaysAgo = workoutsFromSevenDaysAgo.map { $0.totalCompletedWeight ?? 0 }.reduce(0, +)
        let totalWeightFourteenDaysAgo = workoutsFromFourteenDaysAgo.map { $0.totalCompletedWeight ?? 0 }.reduce(0, +)
        
        var weightPercent = totalWeightSevenDaysAgo == 0 ? 0 : (totalWeightSevenDaysAgo / totalWeightFourteenDaysAgo) - 1
        weightPercent = abs(weightPercent) < 0.001 ? 0 : weightPercent
        
        return (totalWeightSevenDaysAgo, weightPercent)
    }
    
    var body: some View {
        let totalTime = self.totalTime
        let totalWeight = self.totalWeight
        
        VStack(alignment: .leading, spacing: 8) {
            Entry(title: durationFormatter.string(from: totalTime.duration)!, percent: totalTime.difference)
            Entry(title: WeightUnit.format(weight: totalWeight.weight, from: .metric, to: settingsStore.weightUnit), percent: totalWeight.difference)
        }
    }
    
    let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
}

private struct Entry: View {
    let title: String
    let percent: Double
    
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            if percent != 0, let percentString = percentString(for: percent) {
                Text(percentString)
                    .foregroundColor(percent < 0 ? .red : .green)
            }
        }
    }
    
    private static var percentNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .percent
        return formatter
    }()
    
    private func percentString(for percent: Double) -> String? {
        guard percent.isFinite else { return nil } // we don't want to display +/- infinity
        return (percent > 0 ? "+" : "") + (Self.percentNumberFormatter.string(from: percent as NSNumber) ?? "\(String(format: "%.1f", percent * 100))%")
    }
}

#if DEBUG
struct ActivitySummaryLast7DaysView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            VStack(alignment: .leading, spacing: 8) {
                Text("活动")
                    .bold()
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                
                Text("过去七天总览")
                    .font(.headline)
                
                Divider()
                
                ActivitySummaryLast7DaysView()
            }
            .padding([.top, .bottom], 8)
        }
        .listStyleCompat_InsetGroupedListStyle()
        .mockEnvironment(weightUnit: .metric)
    }
}
#endif

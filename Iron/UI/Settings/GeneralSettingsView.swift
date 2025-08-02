//
//  GeneralSettingsView.swift
//  Iron
//
//  Created by Karim Abou Zeid on 31.10.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    
    private var weightPickerSection: some View {
        Section {
            Picker("重量单位", selection: $settingsStore.weightUnit) {
                ForEach(WeightUnit.allCases, id: \.self) { weightUnit in
                    Text(weightUnit.title).tag(weightUnit)
                }
            }
        }
    }
    
    private var restTimerTimesSection: some View {
        Section {
            Picker("默认休息时间", selection: $settingsStore.defaultRestTime) {
                ForEach(restTimerCustomTimes, id: \.self) { time in
                    Text(restTimerDurationFormatter.string(from: time) ?? "").tag(time)
                }
            }
            
            Picker("默认休息时间（哑铃）", selection: $settingsStore.defaultRestTimeDumbbellBased) {
                ForEach(restTimerCustomTimes, id: \.self) { time in
                    Text(restTimerDurationFormatter.string(from: time) ?? "").tag(time)
                }
            }
            
            Picker("默认休息时间（杠铃）", selection: $settingsStore.defaultRestTimeBarbellBased) {
                ForEach(restTimerCustomTimes, id: \.self) { time in
                    Text(restTimerDurationFormatter.string(from: time) ?? "").tag(time)
                }
            }
        }
    }
    
    private var restTimerSection: some View {
        Section(footer: Text("即使时间已过，也要保持休息计时器运行。超过的时间以红色显示。")) {
            Toggle("保持休息计时器运行", isOn: Binding(get: {
                settingsStore.keepRestTimerRunning
            }, set: { newValue in
                settingsStore.keepRestTimerRunning = newValue
                
                // TODO in future somehow let RestTimerStore subscribe to this specific change
                RestTimerStore.shared.notifyKeepRestTimerRunningChanged()
            }))
        }
    }
    
    private var oneRmSection: some View {
        Section(footer: Text("组次可以被考虑在最大单次重复(1RM)计算中的最大重复次数。请记住，较高的值不太准确。")) {
            Picker("1RM 的最大重复次数", selection: $settingsStore.maxRepetitionsOneRepMax) {
                ForEach(maxRepetitionsOneRepMaxValues, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
        }
    }
    
    var body: some View {
        Form {
            weightPickerSection
            restTimerTimesSection
            restTimerSection
            oneRmSection
        }
        .navigationBarTitle("通用设置", displayMode: .inline)
    }
}

#if DEBUG
struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
            .mockEnvironment(weightUnit: .metric)
    }
}
#endif

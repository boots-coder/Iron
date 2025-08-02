//
//  WatchSettingsView.swift
//  Iron
//
//  Created by Karim Abou Zeid on 12.11.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import SwiftUI

struct WatchSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    
    private var footer: String {
        if settingsStore.watchCompanion {
            return "当您开始训练时，Iron 的 Apple Watch 配套应用会自动启动，测量您的心率并估算训练期间的卡路里消耗。"
        } else {
            return "当您开始训练时，Iron 的 Apple Watch 配套应用不会自动启动，不会测量您的心率并估算训练期间的卡路里消耗。"
        }
    }
    
    var body: some View {
        Form {
            Section(footer: Text(footer)) {
                Toggle(isOn: $settingsStore.watchCompanion) {
                    Text("Apple Watch 配套应用")
                }
            }
        }
        .navigationBarTitle("Apple Watch", displayMode: .inline)
    }
}

import WatchConnectivity
extension WatchSettingsView {
    static var isSupported: Bool {
        WCSession.isSupported()
    }
}

struct WatchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchSettingsView().environmentObject(SettingsStore.shared)
    }
}

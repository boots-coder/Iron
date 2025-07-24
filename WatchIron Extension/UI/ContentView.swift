import SwiftUI
import WatchKit
import HealthKit

struct ContentView: View {
    var body: some View {
        _ContentView()
            .environmentObject(WorkoutSessionManagerStore.shared)
    }
}

private struct _ContentView: View {
    @EnvironmentObject var workoutSessionManagerStore: WorkoutSessionManagerStore
    
    @State private var selectedTab = "workout"
    
    @ViewBuilder
    var body: some View {
        if workoutSessionManagerStore.workoutSessionManager != nil {
            TabView(selection: $selectedTab) {
                OptionsView()
                    .tag("options")
                
                WorkoutSessionView(workoutSessionManager: workoutSessionManagerStore.workoutSessionManager!)
                    .tag("workout")
                
                NowPlayingView()
                    .tag("now playing")
            }
        } else {
            Group {
                if let s = errorMessage {
                    Text(s).foregroundColor(.red)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "iphone")
                            .imageScale(.large)
                        Text("请在 iPhone 上开始一次训练。") // 替换 "Start a workout on your iPhone."
                            .multilineTextAlignment(.center)
                    }
                }
            }.onAppear {
                self.selectedTab = "workout"
            }
        }
    }
    
    private var errorMessage: String? {
        guard HKHealthStore.isHealthDataAvailable() else {
            return "此设备不支持 HealthKit。" // 替换 "HealthKit is not available on this device."
        }
        
        switch WorkoutSessionManager.healthStore.authorizationStatus(for: .workoutType()) {
        case .notDetermined:
            return nil
        case .sharingAuthorized:
            return nil
        case .sharingDenied:
            return "未授权使用 Apple 健康数据。您可以在设置应用中授权 Iron。" // 替换 "Not authorized for Apple Health."
        @unknown default:
            return nil
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    
    private var mainSection: some View {
        Section {
            NavigationLink(destination: GeneralSettingsView(), isActive: $generalSelected) {
                Text("通用设置") // 替换 "General"
            }
            
            if HealthSettingsView.isSupported {
                NavigationLink(destination: HealthSettingsView()) {
                    Text("Apple 健康") // 替换 "Apple Health"
                }
            }
            
            if WatchSettingsView.isSupported {
                NavigationLink(destination: WatchSettingsView()) {
                    Text("Apple Watch") // 替换 "Apple Watch"
                }
            }
            
            NavigationLink(destination: BackupAndExportView()) {
                Text("备份与导出") // 替换 "Backup & Export"
            }
        }
    }
    
    @State private var showSupportMailAlert = false // 如果未配置邮件客户端
    private var aboutRatingAndSupportSection: some View {
        Section {
            NavigationLink(destination: AboutView()) {
                Text("关于") // 替换 "About"
            }

            Button(action: {
                guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1479893244?action=write-review") else { return }
                UIApplication.shared.open(writeReviewURL)
            }) {
                HStack {
                    Text("为 Iron 评分") // 替换 "Rate Iron"
                    Spacer()
                    Image(systemName: "star")
                }
            }
            
            Button(action: {
                guard MFMailComposeViewController.canSendMail() else {
                    self.showSupportMailAlert = true // 备用方案
                    return
                }
                
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = MailCloseDelegate.shared
                mail.setToRecipients(["iron@ka.codes"])
                
                // TODO: 将此 hack 替换为正确的 rootViewController 获取方式
                guard let rootVC = UIApplication.shared.activeSceneKeyWindow?.rootViewController else { return }
                rootVC.present(mail, animated: true)
            }) {
                HStack {
                    Text("发送反馈") // 替换 "Send Feedback"
                    Spacer()
                    Image(systemName: "paperplane")
                }
            }
            .alert(isPresented: $showSupportMailAlert) {
                Alert(title: Text("支持邮件"), // 替换 "Support E-Mail"
                      message: Text("iron@ka.codes"))
            }
        }
    }
    
    #if DEBUG
    private var developerSettings: some View {
        Section {
            NavigationLink(destination: DeveloperSettings()) {
                Text("开发者设置") // 替换 "Developer"
            }
        }
    }
    #endif

    var body: some View {
        NavigationView {
            Form {
                mainSection
                
                aboutRatingAndSupportSection

                #if DEBUG
                developerSettings
                #endif
            }
            .navigationBarTitle(Text("设置")) // 替换 "Settings"
        }
        .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0) // hack 使主视图在 iPad 上显示
    }
    
    // 默认在 iPad 上选择通用设置选项卡
    @State private var generalSelected = UIDevice.current.userInterfaceIdiom == .pad ? true : false
}

// hack 因为我们无法将此存储在 View 中
private class MailCloseDelegate: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = MailCloseDelegate()
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .mockEnvironment(weightUnit: .metric)
    }
}
#endif

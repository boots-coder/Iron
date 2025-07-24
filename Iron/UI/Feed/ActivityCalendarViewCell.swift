import SwiftUI

struct ActivityCalendarViewCell: View {
    @State private var workoutsLast28Days = WorkoutsLast28DaysKey.defaultValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("活动") // 替换 "Activity"
                .bold()
                .font(.subheadline)
                .foregroundColor(.accentColor)
            
            HStack {
                Text("过去 28 天的训练次数") // 替换 "Workouts Last 28 Days"
                    .font(.headline)
                
                Spacer()
                
                if let workoutsLast28Days = workoutsLast28Days {
                    Text("\(workoutsLast28Days) 次训练") // 替换 "workouts" 为 "次训练"
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            ActivityCalendarHeaderView()
                .padding([.top, .bottom], 4)
            
            Divider()
            
            ActivityCalendarView()
                .frame(height: 250)
                .onPreferenceChange(WorkoutsLast28DaysKey.self, perform: { value in
                    workoutsLast28Days = value
                })
        }
        .padding([.top, .bottom], 8)
    }
}

#if DEBUG
struct ActivityCalendarViewCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActivityCalendarViewCell()
                .mockEnvironment(weightUnit: .metric)
                .previewLayout(.sizeThatFits)
            
            List {
                ActivityCalendarViewCell()
                    .mockEnvironment(weightUnit: .metric)
            }.listStyleCompat_InsetGroupedListStyle()
        }
    }
}
#endif

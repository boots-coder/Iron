//
//  Exercise+SwiftUI.swift
//  Sunrise Fit
//
//  Created by Karim Abou Zeid on 27.06.19.
//  Copyright © 2019 Karim Abou Zeid Software. All rights reserved.
//

import Foundation
import SwiftUI
import WorkoutDataKit

extension Exercise {
    static func colorFor(muscleGroup: String) -> Color {
        switch muscleGroup {
        case "腹部":
            return .yellow
        case "手臂":
            return .purple
        case "肩膀":
            return .orange
        case "背部":
            return .blue
        case "腿部":
            return .green
        case "胸部":
            return .red
        case "未分类":
            return .gray
        default:
            return .secondary
        }
    }
    static func imageFor(muscleGroup: String) -> Image {
        switch muscleGroup {
        case "腹部":
            return Image(systemName: "a.circle.fill")
        case "手臂":
            return Image(systemName: "h.circle.fill")
        case "肩膀":
            return Image(systemName: "s.circle.fill")
        case "背部":
            return Image(systemName: "b.circle.fill")
        case "腿部":
            return Image(systemName: "l.circle.fill")
        case "胸部":
            return Image(systemName: "c.circle.fill")
        case "未分类":
            return Image(systemName: "questionmark.circle.fill")
        default:
            return Image(systemName: "o.circle.fill")
        }
    }
}

extension Exercise {
    var muscleGroupImage: some View {
        Exercise.imageFor(muscleGroup: muscleGroup).foregroundColor(Exercise.colorFor(muscleGroup: muscleGroup))
    }
    
    var muscleGroupColor: Color {
        Exercise.colorFor(muscleGroup: muscleGroup)
    }
}

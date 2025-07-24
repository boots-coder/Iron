//
//  ViewOneRepMax.swift
//  Iron
//
//  Created by bootscoder on 7/24/25.
//  Copyright © 2025 Karim Abou Zeid Software. All rights reserved.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct ViewOneRepMax: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "ViewOneRepMaxIntent"

    static var title: LocalizedStringResource = "View 1RM"
    static var description = IntentDescription("Your highest 1RM.")

    @Parameter(title: "Exercise")
    var exercise: IntentExerciseAppEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("View 1RM for \(\.$exercise)")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$exercise)) { exercise in
            DisplayRepresentation(
                title: "View 1RM for \(exercise!)",
                subtitle: ""
            )
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<IntentWeightAppEntity> {
        // TODO: Place your refactored intent handler code here.
        return .result(value: IntentWeightAppEntity(/* fill in result initializer here */))
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static func exerciseParameterDisambiguationIntro(count: Int, exercise: IntentExerciseAppEntity) -> Self {
        "There are \(count) options matching ‘\(exercise)’."
    }
    static func exerciseParameterConfirmation(exercise: IntentExerciseAppEntity) -> Self {
        "Just to confirm, you wanted ‘\(exercise)’?"
    }
    static func responseSuccess(exercise: IntentExerciseAppEntity, oneRepMax: IntentWeightAppEntity, weight: IntentWeightAppEntity, repetitions: Int) -> Self {
        "Your highest one rep max for \(exercise) was \(oneRepMax). It was computed from a set of \(weight) times \(repetitions)."
    }
    static func responseFailureNoOneRepMax(exercise: IntentExerciseAppEntity) -> Self {
        "You don't have a one rep max for \(exercise)."
    }
}


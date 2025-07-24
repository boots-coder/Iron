//
//  IntentExerciseAppEntity.swift
//  Iron
//
//  Created by bootscoder on 7/24/25.
//  Copyright © 2025 Karim Abou Zeid Software. All rights reserved.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct IntentExerciseAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Exercise")

    struct IntentExerciseAppEntityQuery: EntityQuery {
        func entities(for identifiers: [IntentExerciseAppEntity.ID]) async throws -> [IntentExerciseAppEntity] {
            // TODO: return IntentExerciseAppEntity entities with the specified identifiers here.
            return []
        }

        func suggestedEntities() async throws -> [IntentExerciseAppEntity] {
            // TODO: return likely IntentExerciseAppEntity entities here.
            // This method is optional; the default implementation returns an empty array.
            return []
        }
    }
    static var defaultQuery = IntentExerciseAppEntityQuery()

    var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    var displayString: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }

    init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }
}


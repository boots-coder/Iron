//
//  IntentWeightAppEntity.swift
//  Iron
//
//  Created by bootscoder on 7/24/25.
//  Copyright © 2025 Karim Abou Zeid Software. All rights reserved.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct IntentWeightAppEntity: TransientAppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Weight")

    @Property(title: "Value")
    var value: Double?

    @Property(title: "Unit")
    var unit: String?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Unimplemented")
    }

    init() {
    }
}


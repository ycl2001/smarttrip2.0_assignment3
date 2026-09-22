//
//  smarttrip2_0App.swift
//  smarttrip2.0
//
//  Created by Yen-Chun Liu on 20/9/2026.
//

import CoreData
import SwiftUI

@main
struct smarttrip2_0App: App {
    private let persistenceController: PersistenceController
    private let dependencies: SmartTripDependencies

    init() {
        let persistenceController = PersistenceController.shared
        self.persistenceController = persistenceController
        self.dependencies = SmartTripDependencies(
            context: persistenceController.container.viewContext
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.smartTripDependencies, dependencies)
        }
    }
}

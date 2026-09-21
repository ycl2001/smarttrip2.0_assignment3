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
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

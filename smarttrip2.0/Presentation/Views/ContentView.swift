//
//  ContentView.swift
//  smarttrip2.0
//
//  Created by Yen-Chun Liu on 20/9/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.smartTripDependencies) private var dependencies

    var body: some View {
        if let dependencies {
            SmartTripRootView(dependencies: dependencies)
        } else {
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: "SmartTrip is not ready",
                message: "The app dependencies could not be loaded."
            )
            .tint(SmartTripColors.primary)
        }
    }
}

#Preview {
    ContentView()
}

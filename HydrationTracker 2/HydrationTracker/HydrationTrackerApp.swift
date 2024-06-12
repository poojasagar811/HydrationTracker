//
//  HydrationTrackerApp.swift
//  HydrationTracker
//
//  Created by Crescendo Worldwide India on 11/06/24.
//

import SwiftUI

@main
struct HydrationTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

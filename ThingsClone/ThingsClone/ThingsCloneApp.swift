//
//  ThingsCloneApp.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

@main
struct ThingsCloneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

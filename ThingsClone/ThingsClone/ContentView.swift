//
//  ContentView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingSidebar = false

    var body: some View {
        TabView(selection: $selectedTab) {
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray.fill")
                }
                .tag(0)

            TodayView()
                .tabItem {
                    Label("Today", systemImage: "star.fill")
                }
                .tag(1)

            UpcomingView()
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
                .tag(2)

            AnytimeView()
                .tabItem {
                    Label("Anytime", systemImage: "archivebox.fill")
                }
                .tag(3)

            SomedayView()
                .tabItem {
                    Label("Someday", systemImage: "cloud.fill")
                }
                .tag(4)

            LogbookView()
                .tabItem {
                    Label("Logbook", systemImage: "checkmark.circle.fill")
                }
                .tag(5)
        }
        .accentColor(Color(red: 0.2, green: 0.5, blue: 1.0)) // Things blue
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

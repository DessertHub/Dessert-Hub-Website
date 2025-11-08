//
//  ContentView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }
                .tag(0)

            TodayView()
                .tabItem {
                    Label("Today", systemImage: "star")
                }
                .tag(1)

            UpcomingView()
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
                .tag(2)

            AnytimeView()
                .tabItem {
                    Label("Anytime", systemImage: "archivebox")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.2, green: 0.5, blue: 1.0)) // Things blue
    }
}

// Placeholder views for tabs not in MVP
struct UpcomingView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Upcoming")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Upcoming")
        }
    }
}

struct AnytimeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Anytime")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Anytime")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

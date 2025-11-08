//
//  ContentView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingSearch = false
    @State private var showingProjects = false
    @State private var showingSettings = false

    var body: some View {
        ZStack {
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

            // Floating action buttons
            VStack {
                HStack {
                    Spacer()

                    VStack(spacing: 12) {
                        // Search button
                        Button(action: {
                            showingSearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }

                        // Projects button
                        Button(action: {
                            showingProjects = true
                        }) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }

                        // Settings button
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.trailing, 20)
                }

                Spacer()
            }
            .padding(.top, 60)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView()
        }
        .sheet(isPresented: $showingProjects) {
            ProjectsListView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

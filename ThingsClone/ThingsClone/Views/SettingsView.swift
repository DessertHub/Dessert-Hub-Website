//
//  SettingsView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("showCompletedTasks") private var showCompletedTasks = false
    @AppStorage("defaultList") private var defaultList = "inbox"
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableSounds") private var enableSounds = true
    @AppStorage("themeMode") private var themeMode = "system"
    @AppStorage("enableCloudSync") private var enableCloudSync = false

    var body: some View {
        NavigationView {
            Form {
                // Display settings
                Section {
                    Toggle("Show Completed To-Dos", isOn: $showCompletedTasks)

                    Picker("Default List", selection: $defaultList) {
                        Text("Inbox").tag("inbox")
                        Text("Today").tag("today")
                        Text("Anytime").tag("anytime")
                    }
                } header: {
                    Text("Display")
                }

                // Appearance
                Section {
                    Picker("Theme", selection: $themeMode) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                } header: {
                    Text("Appearance")
                }

                // Notifications
                Section {
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                    Toggle("Sounds", isOn: $enableSounds)
                        .disabled(!enableNotifications)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded about tasks with due dates and scheduled items")
                }

                // Sync
                Section {
                    Toggle("Enable iCloud Sync", isOn: $enableCloudSync)

                    if enableCloudSync {
                        HStack {
                            Text("Status")
                            Spacer()
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Synced")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }

                        Button("Sync Now") {
                            // Trigger sync
                        }
                    }
                } header: {
                    Text("iCloud Sync")
                } footer: {
                    Text("Keep your to-dos in sync across all your devices")
                }

                // Data Management
                Section {
                    NavigationLink("Tags") {
                        TagsView()
                    }

                    NavigationLink("Projects & Areas") {
                        ProjectsListView()
                    }

                    Button("Clear Completed") {
                        // Clear completed tasks
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Data Management")
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}

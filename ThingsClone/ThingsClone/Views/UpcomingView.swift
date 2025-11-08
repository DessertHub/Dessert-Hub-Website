//
//  UpcomingView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct UpcomingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TaskViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.scheduledDate, ascending: true)],
        predicate: NSPredicate(format: "scheduledDate > %@ AND isCompleted == NO", Date() as NSDate),
        animation: .default)
    private var upcomingTasks: FetchedResults<TaskItem>

    @State private var selectedDate: Date?
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""

    private let calendar = Calendar.current

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Calendar Header
                        calendarHeader

                        // Grouped tasks by date
                        ForEach(groupedTasks, id: \.key) { group in
                            Section {
                                VStack(alignment: .leading, spacing: 0) {
                                    // Date header
                                    Text(formatDateHeader(group.key))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)

                                    // Tasks for this date
                                    ForEach(group.value) { task in
                                        TaskRow(task: task) {
                                            viewModel.toggleTaskCompletion(task)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        if upcomingTasks.isEmpty {
                            emptyState
                                .padding(.top, 60)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Upcoming")
                .navigationBarTitleDisplayMode(.large)

                // Quick add button
                quickAddButton
            }
        }
    }

    private var calendarHeader: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Text(currentMonthYear)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                HStack(spacing: 16) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Mini calendar view
            miniCalendar
        }
        .padding(.bottom, 16)
        .background(Color(UIColor.systemBackground))
    }

    private var miniCalendar: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(calendarDates, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date()),
                            hasTask: hasTasksOn(date: date),
                            isToday: calendar.isDateInToday(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text("No Upcoming To-Dos")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Your future tasks will appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var quickAddButton: some View {
        VStack {
            if showingAddTask {
                HStack {
                    TextField("New To-Do", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addTask()
                        }

                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 2)
            } else {
                Button(action: { showingAddTask = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New To-Do")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }

    // MARK: - Helper Properties

    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate ?? Date())
    }

    private var calendarDates: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate ?? Date()))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = firstWeekday - calendar.firstWeekday

        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyDays >= 0 ? leadingEmptyDays : 7 + leadingEmptyDays)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }

        // Pad to complete weeks
        while dates.count % 7 != 0 {
            dates.append(nil)
        }

        return dates
    }

    private var groupedTasks: [(key: Date, value: [TaskItem])] {
        let grouped = Dictionary(grouping: upcomingTasks) { task -> Date in
            if let date = task.scheduledDate {
                return calendar.startOfDay(for: date)
            }
            return calendar.startOfDay(for: Date())
        }

        return grouped.sorted { $0.key < $1.key }
    }

    // MARK: - Helper Methods

    private func hasTasksOn(date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return upcomingTasks.contains { task in
            guard let scheduledDate = task.scheduledDate else { return false }
            return scheduledDate >= startOfDay && scheduledDate < endOfDay
        }
    }

    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }

    private func previousMonth() {
        if let date = calendar.date(byAdding: .month, value: -1, to: selectedDate ?? Date()) {
            selectedDate = date
        }
    }

    private func nextMonth() {
        if let date = calendar.date(byAdding: .month, value: 1, to: selectedDate ?? Date()) {
            selectedDate = date
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }

        let scheduleDate = selectedDate ?? calendar.date(byAdding: .day, value: 1, to: Date())!
        viewModel.createTask(title: newTaskTitle, list: "upcoming", scheduledDate: scheduleDate)
        newTaskTitle = ""
        showingAddTask = false
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasTask: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .cornerRadius(16)

            if hasTask {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
            } else {
                Color.clear.frame(width: 4, height: 4)
            }
        }
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
}

#Preview {
    UpcomingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

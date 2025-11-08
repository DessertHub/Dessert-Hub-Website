# ThingsClone - MVP

A Things-inspired task management app for iOS, built with SwiftUI and CoreData.

## Features (MVP)

### ✅ Completed Features

- **Inbox View**: Capture all incoming tasks
- **Today View**: Tasks scheduled for today
- **Task Management**:
  - Create new tasks with quick add button
  - Edit task details (title, notes, dates)
  - Mark tasks as complete/incomplete
  - Delete tasks
- **Swipe Gestures**:
  - Swipe left to complete
  - Swipe right to delete
- **CoreData Persistence**: All tasks saved locally
- **Things-inspired UI**: Clean, minimal design with blue accent color

### 📋 Task Properties

- Title
- Notes
- Created date
- Scheduled date (for Today view)
- Due date
- Completion status
- List assignment (inbox, today)

## Project Structure

```
ThingsClone/
├── ThingsClone.xcodeproj/          # Xcode project file
├── ThingsClone/
│   ├── ThingsCloneApp.swift        # App entry point
│   ├── ContentView.swift           # Main tab navigation
│   ├── Models/                     # (Empty - using CoreData entities)
│   ├── Views/
│   │   ├── InboxView.swift         # Inbox screen
│   │   ├── TodayView.swift         # Today screen
│   │   ├── TaskRow.swift           # Task list item
│   │   └── TaskEditView.swift      # Task editing sheet
│   ├── ViewModels/
│   │   └── TaskViewModel.swift     # Task CRUD operations
│   ├── CoreData/
│   │   ├── TaskModel.xcdatamodeld/ # CoreData schema
│   │   ├── PersistenceController.swift
│   │   ├── Task+CoreDataClass.swift
│   │   └── Task+CoreDataProperties.swift
│   └── Assets.xcassets/            # App assets
└── README.md
```

## How to Run

1. **Open in Xcode**:
   ```bash
   open ThingsClone.xcodeproj
   ```

2. **Select Target**: Choose an iPhone simulator (iOS 17.0+)

3. **Build and Run**: Press `Cmd + R` or click the Play button

## Usage

### Adding Tasks

- Tap the "New To-Do" button at the bottom of any list
- Enter your task title
- Press Return or tap the + button

### Managing Tasks

- **Complete**: Tap the circle icon or swipe left
- **Delete**: Swipe right
- **Edit**: Tap on a task (coming soon - currently basic editing available)

### Views

- **Inbox**: All uncompleted tasks
- **Today**: Tasks scheduled for today or earlier
- **Upcoming**: Coming soon
- **Anytime**: Coming soon

## Things Features Not Yet Implemented

This is an MVP. Full Things includes:
- Projects and Areas
- Tags
- Headings and Checklists
- Repeating tasks
- Quick Entry window
- Calendar integration
- Cloud sync (Things Cloud)
- Widgets
- Apple Watch app
- Detailed task editing
- Keyboard shortcuts
- And much more...

## Customization Ideas

Since this is for personal use, you can customize:

1. **Colors**: Change accent color in `Assets.xcassets/AccentColor.colorset/`
2. **Gestures**: Modify swipe actions in `InboxView.swift` and `TodayView.swift`
3. **Lists**: Add custom lists by modifying CoreData model
4. **Features**: Add tags, projects, or other Things features you want

## Technical Details

- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Persistence**: CoreData
- **Architecture**: MVVM pattern
- **No external dependencies**

## Next Steps

To make this more like Things, consider adding:

1. Task detail view with full editing
2. Projects and Areas
3. Tags system
4. Repeating tasks
5. Better date scheduling
6. Logbook for completed tasks
7. Search functionality
8. Keyboard shortcuts (iPad)
9. Widgets
10. Dark mode optimization

---

**Built with Claude Code** as a learning project and Things study.

**Token Usage**: See commit messages for development cost tracking.

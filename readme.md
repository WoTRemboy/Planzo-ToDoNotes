<div align="center">
  <img src="https://github.com/user-attachments/assets/146e4d6b-d104-40eb-96c1-133b18df0e2a" alt="Planzo Logo" width="200" height="200">
  <h1>Planzo: ToDo&Notes</h1>
</div>

**Planzo** is a modern iOS & iPadOS task management application built with SwiftUI and Core Data. It provides a clean, intuitive interface for managing tasks, notes, and checklists with features like local notifications, task organization, and data persistence. Find it in [App Store](https://apps.apple.com/us/app/planzo-todo-notes/id6740048231).

## Table of Contents 📋

- [Modules](#modules)
- [Features](#features)
- [Technologies](#technologies)
- [Architecture](#architecture)
- [Testing](#testing)
- [Documentation](#documentation)
- [Requirements](#requirements)

<h2 id="modules">Modules 🧩</h2>

### Main Page
- Overview of all tasks and folders
- Quick access to important and pinned tasks
- Search functionality for finding tasks quickly

<img src="https://github.com/user-attachments/assets/d6083931-2699-48f8-aeeb-c710a06ec3df" alt="Main Page Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/c9e431ed-db38-405e-ac4b-982b3af48590" alt="Main Page" width="200" height="435">
<img src="https://github.com/user-attachments/assets/105f6c21-9e3b-44ce-9aef-c433a7cf4fb9" alt="Search" width="200" height="435">

### Today Page
- Tasks due today
- Upcoming deadlines
- Priority tasks for the day

<img src="https://github.com/user-attachments/assets/773e4a9a-18cd-40a5-a4a6-db0e3facd5a6" alt="Today Page Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/a0e66a27-31b1-4f44-81fe-48ab5fb6598d" alt="Today Page" width="200" height="435">
<img src="https://github.com/user-attachments/assets/79b19156-0328-479f-80d5-bab1ebb3d98b" alt="Search" width="200" height="435">

### Calendar Page
- Monthly calendar view
- Task distribution visualization
- Easy date-based task creation

<img src="https://github.com/user-attachments/assets/f6bd16f3-4723-4e45-871a-98d61ce6e48e" alt="Calendar Page Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/392d6aeb-ac6d-4390-9075-8b85557b3811" alt="Calendar Page" width="200" height="435">
<img src="https://github.com/user-attachments/assets/6fec442a-dc0d-4351-8908-1ac0a3bd7cf9" alt="Date Selector" width="200" height="435">

<h2 id="features">Features ⚒️</h2>

### Task Management
- Create, edit, and delete tasks with detailed information
- Organize tasks into different folders (Tasks, Lists, Reminders, Other)
- Mark tasks as important or pin them for quick access
- Add checklists to tasks for better organization
- Duplicate tasks with all their properties

<img src="https://github.com/user-attachments/assets/9e206f2a-cd63-4c4f-8967-e59224819242" alt="Task Management Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/f0bcc77d-01ea-408c-845c-5b43f7a10204" alt="Task Management" width="200" height="435">
<img src="https://github.com/user-attachments/assets/7ab63094-c88e-47a4-aa9b-68354e95d845" alt="Date Selector" width="200" height="435">

### Push Notifications
- Set up localized local notifications for task deadlines
- Multiple notification types (On time, 5 minutes before, 30 minutes before, 1 hour before, 1 day before)
- Notification management to prevent duplicates
- Notification status tracking and restoration

<img src="https://github.com/user-attachments/assets/02c2f3e6-1b51-4cd4-bb97-fa90417d371d" alt="English Now" width="540" height="90">
<img src="https://github.com/user-attachments/assets/6feb9203-cba1-497d-94d4-2020032599f4" alt="English in 5 Minutes" width="540" height="90">
<img src="https://github.com/user-attachments/assets/3882e94a-42a2-45f6-b22a-4a606507dba4" alt="Russian in 5 Minutes" width="540" height="90">

### Task Organization
- Sort tasks by different criteria
- Search functionality for quick task finding
- Folder-based organization
- Pinned and important task highlighting

### Data Management
- Core Data persistence for reliable data storage
- Batch operations for efficient data handling
- Data cleanup and maintenance features
- Secure data handling and validation

<h2 id="technologies">Technologies 💻</h2>

### iOS Frameworks
- **SwiftUI:** Powers the modern, responsive UI components
- **Core Data:** Handles data persistence and management
- **UserNotifications:** Manages local notifications
- **Combine:** Handles reactive data flow and state management

### Data Management
- **Core Data:** Provides robust data persistence and relationships
- `NSManagedObjectContext`: Manages object lifecycle and changes
- `NSFetchRequest`: Handles data queries and filtering
- `NSPredicate`: Enables complex data filtering

### User Interface
- **SwiftUI Views:** Modern, declarative UI components
- **Custom Animations:** Smooth transitions and interactions

### Push Notifications
- `UNUserNotificationCenter`: Manages local notifications
- `UNNotificationRequest`: Handles notification scheduling
- `UNCalendarNotificationTrigger`: Sets up time-based notifications
- **Notification Extensions**: Custom notification handling

### Logging
- **OSLog:** Integrated for logging essential app data, system events, and debugging information, making it easier to track performance and bugs.

<h2 id="architecture">Architecture 🏗️</h2>

The **Planzo** app follows the MVVM (Model-View-ViewModel) architecture pattern, providing a clean separation of concerns and maintainable code structure.

### Model
The Model layer represents the data and business logic:
- `TaskEntity`: Core Data entity for task storage
- `NotificationEntity`: Handles notification data
- `ChecklistEntity`: Manages checklist items
- `TaskService`: Provides data operations and business logic

### View
The View layer handles UI presentation. Examples:
- `TaskManagementView`: Main task management interface
- `DateSelector`: Date and time selection components
- `NotificationAlert`: Notification management UI
- **Custom UI Components:** Reusable SwiftUI views

### ViewModel
The ViewModel layer manages the presentation logic:
- `TaskManagementViewModel`: Handles task-related logic
- **Notification Management:** Manages notification scheduling
- **Data Validation:** Ensures data integrity
- **State Management:** Handles UI state

<h2 id="testing">Testing 🧪</h2>

### Unit Testing (Examples)
- `TaskManagementViewModelTests`: Tests for task management operations
- `MainViewModelTests`: Tests task filtering, folder selection, search bar toggling, and task creation workflows.
- `SettingsViewModelTests`: Tests initialization, toggling view states, theme changes, notification management, and task creation mode settings.

<h2 id="documentation">Documentation 📚</h2>

The project uses comprehensive documentation following Apple's DocC format:

```swift
/// Compares a folder with the currently selected folder
/// - Parameter folder: The folder to compare with the selected folder
/// - Returns: Boolean indicating if the provided folder matches the selected folder
///
/// This method is used to determine if a folder is currently selected in the UI,
/// enabling proper highlighting and state management in the folder list.
internal func compareFolders(with folder: Folder) -> Bool {
    // code implementation
}
```

<h2 id="requirements">Requirements ✅</h2>

- Xcode 15.0+
- Swift 5.0+
- iOS 17.0+

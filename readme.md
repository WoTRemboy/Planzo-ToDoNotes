<div align="center">
  <img src="https://github.com/user-attachments/assets/146e4d6b-d104-40eb-96c1-133b18df0e2a" alt="Planzo Logo" width="200" height="200">
  <h1>Planzo: ToDo&Notes</h1>
</div>

**Planzo** is a modern iOS task management application built with SwiftUI and Core Data. It provides a clean, intuitive interface for managing tasks, notes, and checklists with features like local notifications, task organization, and data persistence. Find it in [App Store](https://apps.apple.com/us/app/planzo-todo-notes/id6740048231).

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

<img src="https://github.com/user-attachments/assets/eb12149b-de0a-4242-8a42-6ed6c1f89dc4" alt="Main Page Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/3d138e1f-e4b5-4ee5-91fc-89fa30ffab17" alt="Main Page" width="200" height="435">
<img src="https://github.com/user-attachments/assets/62017941-c043-4d9e-8657-2f2c10030598" alt="Search" width="200" height="435">

### Today Page
- Tasks due today
- Upcoming deadlines
- Priority tasks for the day

<img src="https://github.com/user-attachments/assets/570ed794-428b-4948-9705-9ca6f00e30ff" alt="Today Page Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/e87eb838-c35e-45bb-9acf-6040991beab4" alt="Today Page" width="200" height="435">
<img src="https://github.com/user-attachments/assets/a264aa16-c0c5-4ef3-9734-ca6817864210" alt="Search" width="200" height="435">

### Calendar Page
- Monthly calendar view
- Task distribution visualization
- Easy date-based task creation

<img src="https://github.com/user-attachments/assets/e38ba73c-ed6c-4536-8764-112345579241" alt="Calendar Page Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/20b46e74-c676-4c3f-a630-e8eb0f9e60fb" alt="Calendar Page" width="200" height="435">
<img src="https://github.com/user-attachments/assets/864b3aa9-cc3e-4bd1-b0fe-5bff61c69269" alt="Date Selector" width="200" height="435">

<h2 id="features">Features ⚒️</h2>

### Task Management
- Create, edit, and delete tasks with detailed information
- Organize tasks into different folders (Tasks, Lists, Reminders, Other)
- Mark tasks as important or pin them for quick access
- Add checklists to tasks for better organization
- Duplicate tasks with all their properties

<img src="https://github.com/user-attachments/assets/c7bab99b-7cee-4d54-9eb7-5d7a6834db41" alt="Task Management Demo" width="200" height="435">
<img src="https://github.com/user-attachments/assets/7f583c4d-f967-47e4-a40f-d2f79d6546fc" alt="Task Management" width="200" height="435">
<img src="https://github.com/user-attachments/assets/41d77f13-0def-4de7-9b71-c9aeedded3a5" alt="Date Selector" width="200" height="435">

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
- **NSManagedObjectContext:** Manages object lifecycle and changes
- **NSFetchRequest:** Handles data queries and filtering
- **NSPredicate:** Enables complex data filtering

### User Interface
- **SwiftUI Views:** Modern, declarative UI components
- **Custom Animations:** Smooth transitions and interactions

### Push Notifications
- **UNUserNotificationCenter:** Manages local notifications
- **UNNotificationRequest:** Handles notification scheduling
- **UNCalendarNotificationTrigger:** Sets up time-based notifications
- **Notification Extensions:** Custom notification handling

### Logging
- **OSLog:** Integrated for logging essential app data, system events, and debugging information, making it easier to track performance and bugs.

<h2 id="architecture">Architecture 🏗️</h2>

The **Planzo** app follows the MVVM (Model-View-ViewModel) architecture pattern, providing a clean separation of concerns and maintainable code structure.

### Model
The Model layer represents the data and business logic:
- **TaskEntity:** Core Data entity for task storage
- **NotificationEntity:** Handles notification data
- **ChecklistEntity:** Manages checklist items
- **TaskService:** Provides data operations and business logic

### View
The View layer handles UI presentation. Examples:
- **TaskManagementView:** Main task management interface
- **DateSelector:** Date and time selection components
- **NotificationAlert:** Notification management UI
- **Custom UI Components:** Reusable SwiftUI views

### ViewModel
The ViewModel layer manages the presentation logic:
- **TaskManagementViewModel:** Handles task-related logic
- **Notification Management:** Manages notification scheduling
- **Data Validation:** Ensures data integrity
- **State Management:** Handles UI state

<h2 id="testing">Testing 🧪</h2>

### Unit Testing
- **TaskServiceTests:** Tests for task management operations
- **NotificationTests:** Tests for notification scheduling and management
- **DataValidationTests:** Tests for data integrity and validation

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

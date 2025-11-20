//
//  TaskManagementPreviewNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/25/25.
//

import SwiftUI

/// A navigation bar used specifically in the preview screen of a task management view.
struct TaskManagementPreviewNavBar: View {
    
    // MARK: - Properties
    
    /// The task entity to be displayed in the navigation bar.
    private let entity: TaskEntity?
    
    // MARK: - Initialization
        
    /// Initializes the preview navigation bar with an optional task entity.
    /// - Parameter entity: The task entity whose date information should be shown.
    init(entity: TaskEntity?) {
        self.entity = entity
    }
    
    // MARK: - Body
    
    /// The main view body displaying the navigation bar.
    internal var body: some View {
        ZStack(alignment: .center) {
            backgroundColor
            titleSection
        }
        .ignoresSafeArea(edges: .top)
        .frame(height: 60)
    }
    
    // MARK: - Subviews
    
    /// The background color with shadow effect for the navigation bar.
    private var backgroundColor: some View {
        Color.SupportColors.supportNavBar
            .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
    }
    
    /// Displays the task's date (short format) and weekday.
    private var titleSection: some View {
        HStack(spacing: 4) {
            let date = entity?.target ?? entity?.created ?? .distantPast
            
            Text(date.shortDate)
                .font(.system(size: 22, weight: .bold))
            
            Text(date.shortWeekday)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    TaskManagementPreviewNavBar(
        entity: PreviewData.taskItem)
}

//
//  TaskManagementPreview.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/25/25.
//

import SwiftUI

/// A read-only preview screen for viewing task details such as title, description, and checklist items.
struct TaskManagementPreview: View {
    
    // MARK: - Properties
    
    /// ViewModel responsible for managing task-related data in the preview.
    @StateObject private var viewModel = TaskManagementViewModel()
    
    /// The task entity being previewed.
    private let entity: TaskEntity?
        
    // MARK: - Initialization
    
    /// Initializes the preview with a given task entity.
    /// - Parameter entity: The task to display. If provided, initializes the ViewModel with the entity.
    init(entity: TaskEntity?) {
        self.entity = entity
        
        if let entity {
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(entity: entity))
        }
    }
    
    // MARK: - Body
    
    /// Main view body containing navigation bar, background, and task content.
    internal var body: some View {
        ZStack {
            // The background color for the preview screen.
            Color.BackColors.backSheet
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TaskManagementPreviewNavBar(entity: entity)
                    .zIndex(1)
                content
            }
        }
    }
    
    // MARK: - Subviews
    
    /// The main scrollable content showing the task's title, description, and checklist.
    private var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                nameInput
                description
                TaskChecklistView(viewModel: viewModel, preview: true)
                    .padding(.horizontal, -8)
            }
        }
        .padding(.horizontal, 16)
    }
    
    /// Displays the task's title with an optional checkbox.
    private var nameInput: some View {
        HStack {
            if viewModel.check != .none {
                titleCheckbox
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            
            TextField(Texts.TaskManagement.previewTitlePlaceholder,
                      text: $viewModel.nameText)
            .font(.system(size: 20, weight: .medium))
            .lineLimit(1)
            
            .foregroundStyle(
                viewModel.check == .checked
                ? Color.LabelColors.labelDetails
                : Color.LabelColors.labelPrimary)
            .strikethrough(viewModel.check == .checked)
        }
        .padding(.top, 16)
    }
    
    /// Returns the checkbox image depending on the task's check status.
    private var titleCheckbox: Image {
        if viewModel.check == .unchecked {
            Image.TaskManagement.EditTask.Checklist.uncheck
        } else {
            Image.TaskManagement.EditTask.Checklist.check
        }
    }
    
    /// Displays the task's description in a multi-line text field.
    private var description: some View {
        TextField(Texts.TaskManagement.previewDescriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .fixedSize(horizontal: false, vertical: true)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            viewModel.check == .checked
            ? Color.LabelColors.labelDetails
            : Color.LabelColors.labelPrimary)
    }
}

// MARK: - Preview

#Preview {
    TaskManagementPreview(entity: PreviewData.taskItem)
}

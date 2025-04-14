//
//  TaskManagementPreview.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/25/25.
//

import SwiftUI

struct TaskManagementPreview: View {
    
    @StateObject private var viewModel = TaskManagementViewModel()
    
    private let entity: TaskEntity?
        
    init(entity: TaskEntity?) {
        self.entity = entity
        
        if let entity {
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(entity: entity))
        }
    }
    
    internal var body: some View {
        ZStack {
            Color.BackColors.backSheet
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TaskManagementPreviewNavBar(entity: entity)
                    .zIndex(1)
                content
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                nameInput
                descriptionCoverInput
                TaskChecklistView(viewModel: viewModel, preview: true)
                    .padding(.horizontal, -8)
            }
        }
        .padding(.horizontal, 16)
    }
    
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
                viewModel.check == .checked ?
                Color.LabelColors.labelDetails :
                    Color.LabelColors.labelPrimary)
            .strikethrough(viewModel.check == .checked)
        }
        .padding(.top, 16)
    }
    
    private var titleCheckbox: Image {
        if viewModel.check == .unchecked {
            Image.TaskManagement.EditTask.checkListUncheck
        } else {
            Image.TaskManagement.EditTask.checkListCheck
        }
    }
    
    private var descriptionCoverInput: some View {
        TextField(Texts.TaskManagement.previewDescriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .fixedSize(horizontal: false, vertical: true)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            viewModel.check == .checked ?
            Color.LabelColors.labelDetails :
                Color.LabelColors.labelPrimary)
    }
}

#Preview {
    TaskManagementPreview(entity: PreviewData.taskItem)
}

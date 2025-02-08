//
//  TaskListRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/13/25.
//

import SwiftUI
import CoreData

struct TaskListRow: View {
    
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    private var entity: TaskEntity
    
    init(entity: TaskEntity) {
        self.entity = entity
    }
    
    internal var body: some View {
        HStack(spacing: 0) {
            folderIndicatior
            if entity.completed != 0 {
                checkBoxButton
            }
            nameLabel
            
            Spacer()
            detailsBox
            //additionalStatus
        }
    }
    
    private var folderIndicatior: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
            .frame(maxWidth: 1, maxHeight: .infinity)
            .padding(.trailing, 14)
    }
    
    private var checkBoxButton: some View {
        (coreDataManager.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.checkedBox :
            Image.TaskManagement.TaskRow.uncheckedBox)
            .resizable()
            .frame(width: 15, height: 15)
        
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    coreDataManager.toggleCompleteChecking(for: entity)
                }
            }
            .padding(.trailing, 8)
    }
    
    private var nameLabel: some View {
        Text(entity.name ?? String())
            .font(.system(size: 15, weight: .medium))
            .lineLimit(1)
            .foregroundStyle(coreDataManager.taskCheckStatus(for: entity) ?
                             Color.LabelColors.labelDetails :
                                Color.LabelColors.labelPrimary)
            .strikethrough(coreDataManager.taskCheckStatus(for: entity),
                           color: Color.LabelColors.labelDetails)
    }
    
    private var detailsBox: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if entity.target != nil, entity.hasTargetTime {
                dateLabel
            }
            
            HStack(spacing: 2) {
                if coreDataManager.haveTextContent(for: entity) {
                    textContentImage
                }
                if let notifications = entity.notifications,
                   notifications.count > 0 {
                    remainderImage
                }
            }
        }
        .padding(.leading)
        .padding(.trailing, 22)
    }
    
    private var dateLabel: some View {
        Text(entity.target?.fullHourMinutes ?? String())
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(coreDataManager.taskCheckStatus(for: entity) ?
                             Color.LabelColors.labelDetails :
                                Color.LabelColors.labelPrimary)
    }
    
    private var remainderImage: some View {
        (coreDataManager.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.checkedRemainder :
            Image.TaskManagement.TaskRow.uncheckedRemainder)
            .resizable()
            .frame(width: 12, height: 12)
    }
    
    private var textContentImage: some View {
        (coreDataManager.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.checkedContent :
            Image.TaskManagement.TaskRow.uncheckedContent)
            .resizable()
            .frame(width: 12, height: 12)
    }
    
    private var additionalStatus: some View {
        VStack(spacing: 2) {
            Image(String())
                .resizable()
                .frame(width: 12, height: 12)
                .padding(.leading, 5)
            
            Rectangle()
                .foregroundStyle(Color.clear)
                .frame(width: 12, height: 12)
        }
        .padding(.trailing, 6)
    }
}

#Preview {
    let coreDataManager = CoreDataViewModel()
    
    return TaskListRow(entity: coreDataManager.savedEnities.last!)
        .environmentObject(coreDataManager)
}

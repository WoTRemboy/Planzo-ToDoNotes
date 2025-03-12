//
//  TaskManagementNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct TaskManagementNavBar: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    private let entity: TaskEntity?
    private let onDismiss: () -> Void
    
    init(viewModel: TaskManagementViewModel,
         entity: TaskEntity?,
         onDismiss: @escaping () -> Void) {
        self.entity = entity
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    HStack {
                        backButton
                        titleLabel
                        moreButton
                    }
                }
                .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Image.NavigationBar.hide
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.leading)
    }
    
    private var titleLabel: some View {
        HStack(spacing: 4) {
            Text(Texts.TaskManagement.today)
                .font(.system(size: 22, weight: .bold))
                .padding(.leading)
            
            Text(viewModel.todayDate.shortDate)
                .font(.system(size: 22, weight: .bold))
            
            Text(viewModel.todayDate.shortWeekday)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var shareButton: some View {
        Button {
            // Share Action
        } label: {
            Image.NavigationBar.share
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.clear)
                .frame(width: 22, height: 22)
        }
        .disabled(true)
        .padding(.trailing)
    }
    
    private var moreButton: some View {
        Menu {
//            Button {
//                // Complete Status Action
//            } label: {
//                Label {
//                    Text(Texts.TaskManagement.ContextMenu.complete)
//                } icon: {
//                    Image.TaskManagement.EditTask.Menu.completed
//                        .renderingMode(.template)
//                }
//            }
//            
//            Button {
//                // Dublicate Task Action
//            } label: {
//                Label {
//                    Text(Texts.TaskManagement.ContextMenu.dublicate)
//                } icon: {
//                    Image.TaskManagement.EditTask.Menu.copy
//                        .renderingMode(.template)
//                }
//            }
            
            Section {
                Button {
                    viewModel.toggleImportanceCheck()
                    Toast.shared.present(
                        title: viewModel.importance ?
                            Texts.Toasts.importantOn :
                            Texts.Toasts.importantOff)
                } label: {
                    Label {
                        viewModel.importance ?
                        Text(Texts.TaskManagement.ContextMenu.importantDeselect) :
                        Text(Texts.TaskManagement.ContextMenu.important)
                    } icon: {
                        viewModel.importance ?
                        Image.TaskManagement.EditTask.Menu.importantDeselect :
                        Image.TaskManagement.EditTask.Menu.importantSelect
                            .renderingMode(.template)
                    }
                }
                
                Button {
                    viewModel.togglePinnedCheck()
                    Toast.shared.present(
                        title: viewModel.pinned ?
                            Texts.Toasts.pinnedOn :
                            Texts.Toasts.pinnedOff)
                } label: {
                    Label {
                        viewModel.pinned ?
                        Text(Texts.TaskManagement.ContextMenu.unpin) :
                        Text(Texts.TaskManagement.ContextMenu.pin)
                    } icon: {
                        viewModel.pinned ?
                        Image.TaskManagement.EditTask.Menu.pinnedDeselect :
                        Image.TaskManagement.EditTask.Menu.pinnedSelect
                            .renderingMode(.template)
                    }
                }
                
//                if let entity {
//                    Button(role: .destructive) {
//                        do {
//                            try TaskService.toggleRemoved(for: entity)
//                            onDismiss()
//                            Toast.shared.present(
//                                title: Texts.Toasts.removed)
//                        } catch {
//                            print("Task could not be removed with error: \(error.localizedDescription).")
//                        }
//                    } label: {
//                        Label {
//                            Text(Texts.TaskManagement.ContextMenu.delete)
//                        } icon: {
//                            Image.TaskManagement.EditTask.Menu.trash
//                                .renderingMode(.template)
//                        }
//                    }
//                }
            }
        } label: {
            Image.NavigationBar.more
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.trailing)
    }
}

#Preview {
    TaskManagementNavBar(
        viewModel: TaskManagementViewModel(),
        entity: PreviewData.taskItem,
        onDismiss: {})
}

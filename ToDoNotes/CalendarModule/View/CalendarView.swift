//
//  CalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var viewModel: CalendarViewModel
//    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    
    @Namespace private var animation
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popView(isPresented: $viewModel.showingCalendarSelector, onDismiss: {}) {
            CalendarMonthSelector()
        }
        
//        .onAppear {
//            coreDataManager.dayTasks(for: viewModel.selectedDate)
//        }
//        .onChange(of: coreDataManager.savedEnities) {
//            withAnimation {
//                coreDataManager.dayTasks(for: viewModel.selectedDate)
//            }
//        }
//        .onChange(of: coreDataManager.dayTasksHasUpdated) {
//            withAnimation {
//                coreDataManager.dayTasks(for: viewModel.selectedDate)
//            }
//        }
        
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                selectedDate: viewModel.selectedDate,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
                }
                .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                entity: task,
                namespace: animation) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            CalendarNavBar(date: Texts.CalendarPage.today,
                           monthYear: viewModel.calendarDate)
            .zIndex(1)
            
            CustomCalendarView(namespace: animation)
                .padding(.top)
            
            separator
            
//            if coreDataManager.dayTasks.isEmpty {
//                placeholder
//            } else {
//                taskForm
//                    .padding(.top, 1)
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.15),
                   value: viewModel.selectedDate)
    }
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
            .frame(height: 0.36)
            .padding([.top, .horizontal])
    }
    
//    private var taskForm: some View {
//        Form {
//            ForEach(TaskSection.availableRarities(for: coreDataManager.dayTasks.keys), id: \.self) { section in
//                taskSection(for: section)
//            }
//            .listRowSeparator(.hidden)
//            .listSectionSpacing(0)
//        }
//        .padding(.horizontal, hasNotch() ? -4 : 0)
//        .background(Color.BackColors.backDefault)
//        .shadow(color: Color.ShadowColors.shadowTaskSection, radius: 10, x: 2, y: 2)
//        .scrollContentBackground(.hidden)
//    }
    
//    @ViewBuilder
//    private func taskSection(for section: TaskSection) -> some View {
//        Section {
//            let tasks = coreDataManager.dayTasks[section] ?? []
//            ForEach(tasks) { entity in
//                Button {
//                    viewModel.selectedTask = entity
//                } label: {
//                    TaskListRow(entity: entity, isLast: tasks.last == entity)
//                }
//                .swipeActions(edge: .leading, allowsFullSwipe: false) {
//                    Button {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            coreDataManager.toggleImportant(for: entity)
//                        }
//                    } label: {
//                        coreDataManager.taskCheckImportant(for: entity) ?
//                        Image.TaskManagement.TaskRow.SwipeAction.importantDeselect :
//                        Image.TaskManagement.TaskRow.SwipeAction.important
//                    }
//                    .tint(Color.SwipeColors.important)
//                    
//                    Button(role: .destructive) {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            coreDataManager.togglePinned(for: entity)
//                            coreDataManager.dayTasks(for: viewModel.selectedDate)
//                        }
//                    } label: {
//                        coreDataManager.taskCheckPinned(for: entity) ?
//                        Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect :
//                        Image.TaskManagement.TaskRow.SwipeAction.pinned
//                    }
//                    .tint(Color.SwipeColors.pin)
//                }
//                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                    Button(role: .destructive) {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            coreDataManager.toggleRemoved(for: entity)
//                        }
//                    } label: {
//                        Image.TaskManagement.TaskRow.SwipeAction.remove
//                    }
//                    .tint(Color.SwipeColors.remove)
//                }
//            }
//            .listRowInsets(EdgeInsets())
//        } header: {
//            if section == .active {
//                Text(viewModel.selectedDate.longDayMonthWeekday)
//                    .font(.system(size: 15, weight: .medium))
//                    .textCase(.none)
//                    .contentTransition(.numericText(value: viewModel.selectedDate.timeIntervalSince1970))
//                    .matchedGeometryEffect(
//                        id: Texts.NamespaceID.selectedCalendarDate,
//                        in: animation)
//            } else {
//                Text(section.name)
//                    .font(.system(size: 15, weight: .medium))
//                    .textCase(.none)
//            }
//        }
//    }
    
    private var placeholder: some View {
        ScrollView {
            CalendarTaskFormPlaceholder(
                date: viewModel.selectedDate,
                namespace: animation)
            .padding(.top)
        }
        .scrollDisabled(true)
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            Button {
                viewModel.toggleShowingTaskCreateView()
            } label: {
                Image.TaskManagement.plus
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
            }
            .navigationTransitionSource(id: Texts.NamespaceID.selectedEntity,
                                        namespace: animation)
            .padding()
            .glow(available: viewModel.addTaskButtonGlow)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
//        .environmentObject(CoreDataViewModel())
}

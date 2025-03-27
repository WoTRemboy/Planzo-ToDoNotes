//
//  TaskManagementPreviewNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/25/25.
//

import SwiftUI

struct TaskManagementPreviewNavBar: View {
    
    private let entity: TaskEntity?
    
    init(entity: TaskEntity?) {
        self.entity = entity
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    titleLabel
                }
                .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var titleLabel: some View {
        HStack(spacing: 4) {
            let target = entity?.target ?? entity?.created ?? .distantPast
            
            Text(target.shortDate)
                .font(.system(size: 22, weight: .bold))
            
            Text(target.shortWeekday)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                
        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TaskManagementPreviewNavBar(
        entity: PreviewData.taskItem)
}

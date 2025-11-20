//
//  SharingAccessView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 18/11/2025.
//

import SwiftUI

struct SharingAccessView: View {
    
    @EnvironmentObject private var authService: AuthNetworkService
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            accessStack
        }
        .safeAreaInset(edge: .bottom) {
            safeAreaContent
        }
        .customNavBarItems(
            title: Texts.TaskManagement.SharingAccess.title,
            showBackButton: true)
        .task {
            viewModel.loadMembersForSharingTask()
        }
        .sheet(item: $viewModel.selectedMember) { item in
            SharingAccessManageView(viewModel: viewModel) {
                viewModel.setSelectedMember(to: nil)
            }
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var accessUsersLabel: some View {
        Text(Texts.TaskManagement.SharingAccess.allowedUsers)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color.LabelColors.labelSecondary)
    }
    
    private var accessStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            accessUsersLabel
            ownerRow
            ForEach(viewModel.shareMembers, id: \.userSub) { member in
                Button {
                    viewModel.setSelectedMember(to: member)
                } label: {
                    SharingAccessProfileRow(member: member, viewModel: viewModel)
                }
            }
        }
        .animation(.spring(duration: 0.2), value: viewModel.shareMembers)
        .padding([.horizontal, .top])
    }
    
    private var ownerRow: some View {
        let member = SharingMember(id: authService.currentUser?.email ?? "", listId: "", userSub: "", role: ShareAccess.owner.rawValue, revoked: false, addedAt: "", addedBy: "", updatedAt: "")
        return SharingAccessProfileRow(member: member, imageURL: authService.currentUser?.avatarUrl, viewModel: viewModel)
    }
    
    private var safeAreaContent: some View {
        removeAccessButton
            .frame(maxWidth: .infinity)
            .background {
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: -5)
                    .ignoresSafeArea()
            }
    }
    
    private var removeAccessButton: some View {
        Button {
            
        } label: {
            removeAccessView
        }
        .padding(.bottom, hasNotch() ? 0 : 16)
    }
    
    private var removeAccessView: some View {
        Text(Texts.TaskManagement.SharingAccess.closeAccess)
            .font(.system(size: 17, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .lineLimit(1)
        
            .foregroundColor(Color.LabelColors.labelReversed)
            .background(Color.LabelColors.labelPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
            .frame(height: 50)
            .minimumScaleFactor(0.4)
            .padding([.horizontal, .top], 16)
    }
}

#Preview {
    SharingAccessView(viewModel: TaskManagementViewModel())
        .environmentObject(AuthNetworkService())
}

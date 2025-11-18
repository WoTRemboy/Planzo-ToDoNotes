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
        .customNavBarItems(
            title: Texts.TaskManagement.SharingAccess.title,
            showBackButton: true)
        .task {
            viewModel.loadMembersForSharingTask()
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
                SharingAccessProfileRow(member: member, viewModel: viewModel)
            }
        }
        .padding([.horizontal, .top])
    }
    
    private var ownerRow: some View {
        let member = SharingMember(id: authService.currentUser?.email ?? "", listId: "", userSub: "", role: ShareAccess.owner.rawValue, revoked: false, addedAt: "", addedBy: "", updatedAt: "")
        return SharingAccessProfileRow(member: member, imageURL: authService.currentUser?.avatarUrl, viewModel: viewModel)
    }
}

#Preview {
    SharingAccessView(viewModel: TaskManagementViewModel())
        .environmentObject(AuthNetworkService())
}

//
//  SharingAccessProfileRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 18/11/2025.
//

import SwiftUI

struct SharingAccessProfileRow: View {
    
    @EnvironmentObject private var authService: AuthNetworkService
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    private let member: SharingMember
    private let imageURL: String?
    
    init(member: SharingMember, imageURL: String? = nil, viewModel: TaskManagementViewModel) {
        self.member = member
        self.imageURL = imageURL
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            leftLabel    // Main label with optional image and title
            
            Spacer()
            // Chevron if enabled
            if !viewModel.isOwner(for: member) {
                Image.NavigationBar.hide
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background(Color.SupportColors.supportButton)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    // MARK: - Components
    
    /// Label view displaying the optional image and title on the left.
    private var leftLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            if let imageURL {
                AsyncImage(url: URL(string: imageURL)) { result in
                    if let image = result.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        placeholderImage
                    }
                }
                .clipShape(.circle)
                .frame(width: 36, height: 36)
            } else {
                placeholderImage
            }
            textDetailsBlock
        }
    }
    
    private var placeholderImage: some View {
        EmailInitialCircleView(email: viewModel.isOwner(for: member) ? member.id : String(member.id.suffix(member.id.count - 6)), type: .small)
            .frame(width: 36, height: 36)
    }
    
    private var textDetailsBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.isOwner(for: member) ? member.id : "\(Texts.TaskManagement.SharingAccess.user): \(String(member.id.prefix(8)))")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
            
            // Optional details text
            if let role = ShareAccess(rawValue: member.role)?.name {
                Text(role)
                    .font(.system(size: 13,
                                  weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .lineLimit(1)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: member.role)
            }
        }
    }
}

#Preview {
    let mock = SharingMember.mock
    SharingAccessProfileRow(member: mock, viewModel: TaskManagementViewModel())
        .environmentObject(AuthNetworkService())
}

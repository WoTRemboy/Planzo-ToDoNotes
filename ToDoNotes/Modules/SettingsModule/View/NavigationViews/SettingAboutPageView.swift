//
//  SettingAboutPageView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/28/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// A screen displaying information about the application, including name, version, and copyright.
struct SettingAboutPageView: View {
    
    /// Provides access to app metadata such as name, version, and build number.
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State private var buttonsTapCount: Int = 0
    @State private var showJsonButtons: Bool = false
    
    // MARK: - Body
    
    internal var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.top, 100)
                .customNavBarItems(
                    title: Texts.Settings.About.title,
                    showBackButton: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .fileImporter(isPresented: $viewModel.isImporting, allowedContentTypes: [UTType.json]) { result in
            viewModel.importFromPickerResult(result) { importResult in
                switch importResult {
                case .success:
                    viewModel.importAlertMessage = Texts.Settings.About.JSON.importSuccess
                    viewModel.showingImportAlert = true
                case .failure(let error):
                    viewModel.importAlertMessage = "\(Texts.Settings.About.JSON.importFailed): \(error.localizedDescription)"
                    viewModel.showingImportAlert = true
                }
            }
        }
        .alert(Texts.Settings.About.JSON.exportData, isPresented: $viewModel.showingExportAlert, actions: {
            Button(Texts.Settings.ok, role: .cancel) { }
        }, message: {
            Text(viewModel.exportAlertMessage)
        })
        .alert(Texts.Settings.About.JSON.importData, isPresented: $viewModel.showingImportAlert, actions: {
            Button(Texts.Settings.ok, role: .cancel) { }
        }, message: {
            Text(viewModel.importAlertMessage)
        })
        .sheet(isPresented: $viewModel.isSharing) {
            if let url = viewModel.shareURL {
                ActivityView(activityItems: [url])
            }
        }
    }
    
    // MARK: - Main Content
    
    /// The main content stack containing the app logo, name, version, and copyright.
    private var content: some View {
        VStack(spacing: 0) {
            appLogo
            appName
                .padding(.top, 24)
            version
                .padding(.top, 50)
            
            if showJsonButtons {
                jsonButtons
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
            }
        }
    }
    
    /// Displays the app logo image.
    private var appLogo: some View {
        Image.Settings.aboutLogo
            .resizable()
            .frame(width: 185, height: 185)
            .clipShape(
                RoundedRectangle(cornerRadius: 40)
            )
    }
    
    /// Displays the app name.
    private var appName: some View {
        Text(viewModel.appName)
            .font(.system(size: 25, weight: .bold))
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .contentShape(Rectangle())
            .onTapGesture {
                buttonsTapCount += 1
                if buttonsTapCount >= 10 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showJsonButtons = true
                    }
                }
            }
    }
    
    /// Displays the app version and copyright.
    private var version: some View {
        VStack(spacing: 8) {
            Text("\(Texts.Settings.About.version) \(viewModel.appVersion) (\(viewModel.buildVersion))")
                .font(.system(size: 18, weight: .medium))
            
            Text(Texts.Settings.About.copyright)
                .font(.system(size: 14, weight: .regular))
        }
    }
    
    private var jsonButtons: some View {
        VStack(spacing: 16) {
            Button(action: exportJSON) {
                Text(Texts.Settings.About.JSON.exportData)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Button(action: { viewModel.isImporting = true }) {
                Text(Texts.Settings.About.JSON.importData)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.LabelColors.labelPrimary.opacity(0.08))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Actions
    private func exportJSON() {
        viewModel.exportJSON { result in
            switch result {
            case .success(let url):
                viewModel.lastExportURL = url
                viewModel.exportAlertMessage = "\(Texts.Settings.About.JSON.exportSuccess): \(url.lastPathComponent)"
                viewModel.shareURL = url
                viewModel.isSharing = true
                viewModel.showingExportAlert = false
            case .failure(let error):
                viewModel.exportAlertMessage = "\(Texts.Settings.About.JSON.exportFailed): \(error.localizedDescription)"
                viewModel.showingExportAlert = true
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    SettingAboutPageView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}


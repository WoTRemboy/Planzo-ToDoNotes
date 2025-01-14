//
//  SettingsView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    internal var body: some View {
        NavigationStack {
            ZStack {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            SettingsNavBar()
            paramsForm
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .fullScreenCover(isPresented: $viewModel.showingAppearance) {
            SettingAppearanceView()
                .transition(.move(edge: .leading))
        }
    }
    
    private var paramsForm: some View {
        Form {
            aboutAppSection
            application
            contact
        }
        .padding(.horizontal, -10)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
    }
    
    private var aboutAppSection: some View {
        Section {
            AboutAppView(name: viewModel.appName,
                         version: viewModel.appVersion)
        } header: {
            Text(Texts.Settings.About.title)
                .font(.system(size: 13, weight: .regular))
                .textCase(.none)
        }
        .listRowBackground(Color.SupportColors.backListRow)
    }
    
    private var application: some View {
        Section {
            // Change language button
            Button {
                viewModel.toggleShowingLanguageAlert()
            } label: {
                SettingFormRow(
                    title: Texts.Settings.Language.title,
                    image: Image.Settings.language,
                    details: Texts.Settings.Language.details,
                    chevron: true)
            }
            .listRowBackground(Color.SupportColors.backListRow)
            
            .alert(isPresented: $viewModel.showingLanguageAlert) {
                // Change language alert
                Alert(
                    title: Text(Texts.Settings.Language.alertTitle),
                    message: Text(Texts.Settings.Language.alertContent),
                    primaryButton: .default(Text(Texts.Settings.Language.settings)) {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    },
                    secondaryButton: .cancel(Text(Texts.Settings.cancel))
                )
            }
            
            // Change theme button
            Button {
                viewModel.toggleShowingAppearance()
            } label: {
                SettingFormRow(
                    title: Texts.Settings.Appearance.title,
                    image: Image.Settings.appearance,
                    details: viewModel.userTheme.name,
                    chevron: true)
            }
            .listRowBackground(Color.SupportColors.backListRow)
        } header: {
             Text(Texts.Settings.Language.sectionTitle)
                .font(.system(size: 13, weight: .regular))
                .textCase(.none)
        }
    }
    
    private var contact: some View {
        Section {
            Link(destination: URL(string: "mailto:\(Texts.Settings.Email.emailContent)")!, label: {
                SettingFormRow(
                    title: Texts.Settings.Email.emailTitle,
                    image: Image.Settings.email,
                    details: Texts.Settings.Email.emailContent,
                    chevron: true)
            })
        } header: {
            Text(Texts.Settings.Email.contact)
                .font(.system(size: 13, weight: .regular))
                .textCase(.none)
        }
        .listRowBackground(Color.SupportColors.backListRow)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}

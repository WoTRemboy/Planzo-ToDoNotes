//
//  ColorExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

extension Color {
    
    // MARK: - Back Colors
    
    enum BackColors {
        static let backElevated = Color("BackElevated")
        static let backiOSPrimary = Color("BackiOSPrimary")
        static let backPrimary = Color("BackPrimary")
        static let backSecondary = Color("BackSecondary")
        static let backDefault = Color("BackDefault")
        static let backSheet = Color("BackSheet")
        static let backFormCell = Color("BackFormCell")
    }
    
    // MARK: - Button Colors
    
    enum ButtonColors {
        static let onboarding = Color("OnboardingButton")
        static let appleLogin = Color("AppleLoginButton")
        static let remove = Color ("RemoveButton")
    }
    
    // MARK: - Label Colors
    
    enum LabelColors {
        static let labelDisable = Color("LabelDisable")
        static let labelDetails = Color("LabelDetails")
        static let labelPrimary = Color("LabelPrimary")
        static let labelSecondary = Color("LabelSecondary")
        static let labelTertiary = Color("LabelTertiary")
        static let labelReversed = Color("LabelReversed")
        static let labelBlack = Color("LabelBlack")
        static let labelGreyLight = Color("LabelGreyLight")
        static let labelGreyDark = Color("LabelGreyDark")
        static let labelPlaceholder = Color("LabelPlaceholder")
        
        enum Special {
            static let labelFilterUnselected = Color("LabelFilterUnselected")
            static let labelSearchBarCancel = Color("LabelSearchBarCancel")
        }
    }
    
    // MARK: - Support Colors
    
    enum SupportColors {
        static let supportNavBar = Color("SupportNavBar")
        static let supportOverlay = Color("SupportOverlay")
        static let supportSegmented = Color("SupportSegmented")
        static let supportTextField = Color("SupportTextField")
        static let supportListRow = Color("SupportListRow")
        static let supportButton = Color("SupportButton")
        static let supportToggle = Color("SupportToggle")
        static let supportPopup = Color("SupportPopup")
        static let supportParamRow = Color("SupportParamRow")
    }
    
    // MARK: - Folder Colors
    
    enum FolderColors {
        static let all = Color("FolderAll")
        static let reminders = Color("FolderReminders")
        static let tasks = Color("FolderTasks")
        static let lists = Color("FolderLists")
        static let other = Color("FolderOther")
    }
    
    // MARK: - Shadow Colors
    
    enum ShadowColors {
        static let navBar = Color("ShadowNavBarColor")
        static let popup = Color("ShadowPopupColor")
        static let taskSection = Color("ShadowTaskSectionColor")
    }
    
    // MARK: - Swipe Colors
    
    enum SwipeColors {
        static let important = Color("SwipeActionImportant")
        static let pin = Color("SwipeActionPin")
        static let remove = Color("SwipeActionDelete")
        static let restore = Color("SwipeActionRestore")
        static let duplicate = Color("SwipeActionDuplicate")
    }
}


// MARK: - UIColor Extension

extension UIColor {
    
    // MARK: - Shadow Colors (UIColor)
    
    enum ShadowColors {
        static let navBar = UIColor(named: "ShadowNavBarColor")
    }
    
    // MARK: - TabBar Colors (UIColor)
    
    enum TabBar {
        static let background = UIColor(named: "SupportNavBar")
    }
}

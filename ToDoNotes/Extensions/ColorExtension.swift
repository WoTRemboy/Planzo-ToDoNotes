//
//  ColorExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

extension Color {
    enum BackColors {
        static let backElevated = Color("BackElevated")
        static let backiOSPrimary = Color("BackiOSPrimary")
        static let backPrimary = Color("BackPrimary")
        static let backSecondary = Color("BackSecondary")
        static let backSplash = Color("BackSplash")
        static let backPopup = Color("BackPopup")
        static let backDefault = Color("BackDefault")
        static let backTableView = Color("BackTableView")
        static let backSheetView = Color("BackSheetView")
        static let backFormCell = Color("BackFormCell")
    }
    
    enum ButtonColors {
        static let onboarding = Color("OnboardingButton")
        static let appleLogin = Color("AppleLoginButton")
        static let remove = Color ("RemoveButton")
    }
    
    enum LabelColors {
        static let labelDisable = Color("LabelDisable")
        static let labelDetails = Color("LabelDetails")
        static let labelPrimary = Color("LabelPrimary")
        static let labelSecondary = Color("LabelSecondary")
        static let labelTertiary = Color("LabelTertiary")
        static let labelReversed = Color("LabelReversed")
    }
    
    enum SupportColors {
        static let supportNavBar = Color("SupportNavBar")
        static let supportOverlay = Color("SupportOverlay")
        static let supportSegmented = Color("SupportSegmented")
        static let supportTextField = Color("SupportTextField")
        static let backListRow = Color("SupportListRow")
    }
    
    enum FolderColors {
        static let all = Color("FolderAll")
        static let noDate = Color("FolderNoDate")
        static let lists = Color("FolderLists")
        static let passwords = Color("FolderPasswords")
    }
    
    enum ShadowColors {
        static let shadowDefault = Color("ShadowDefaultColor")
        static let shadowTaskSection = Color("ShadowTaskSectionColor")
    }
    
    enum SwipeColors {
        static let important = Color("SwipeActionImportant")
        static let pin = Color("SwipeActionPin")
        static let remove = Color("SwipeActionDelete")
        static let restore = Color("SwipeActionRestore")
    }
}


extension UIColor {
    enum ShadowColors {
        static let defaultShadow = UIColor(named: "ShadowDefaultColor")
    }
}

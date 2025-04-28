//
//  ResetMessageModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/6/25.
//

/// Represents the result status of a reset operation.
enum ResetMessage {
    
    // MARK: - Cases
    
    /// Reset completed successfully.
    case success
    /// Reset failed due to an error.
    case failure
    /// No data to reset.
    case empty
    
    // MARK: - Properties
    
    /// The title corresponding to the reset result.
    internal var title: String {
        switch self {
        case .success:
            Texts.Settings.Reset.success
        case .failure:
            Texts.Settings.Reset.failure
        case .empty:
            Texts.Settings.Reset.empty
        }
    }
    
    /// The detailed message corresponding to the reset result.
    internal var message: String {
        switch self {
        case .success:
            Texts.Settings.Reset.successMessage
        case .failure:
            Texts.Settings.Reset.failureMessage
        case .empty:
            Texts.Settings.Reset.emptyMessage
        }
    }
}

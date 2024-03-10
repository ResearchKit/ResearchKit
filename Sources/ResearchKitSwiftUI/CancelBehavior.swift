//
// This source file is part of the Stanford Biodesign Digital Health Group open-source organization
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Define the behavior of the cancel button of the `ORKOrderedTaskView`
public enum CancelBehavior {
    /// The cancel button is not shown.
    case disabled
    /// Shows a confirmation dialog before canceling the view.
    case shouldConfirmCancel
    /// Cancel button without a confirmation dialog.
    case cancel
}

//
//  AppViewModel.swift
//  Phoenix
//
//  Created by jxhug on 1/3/24.
//

import Foundation

@MainActor
class AppViewModel: ObservableObject {
    // toast
    @Published var showSuccessToast: Bool = false
    @Published var successToastText: String = "Success"
    @Published var showFailureToast: Bool = false
    @Published var failureToastText: String = "Failure"
    
    @Published var isAddingGame: Bool = false
    @Published var isEditingGame: Bool = false
    @Published var isPlayingGame: Bool = false
    
    func showSuccessToast(_ message: String) {
        successToastText = message
        showSuccessToast = true
    }
    
    func showFailureToast(_ message: String) {
        failureToastText = message
        showFailureToast = true
    }
}

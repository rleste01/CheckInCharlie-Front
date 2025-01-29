//
//  SessionManager.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//

import Foundation
import Combine
import SwiftUI

class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userId: Int?

    private var cancellables = Set<AnyCancellable>()

    @AppStorage("authToken") private var authToken: String = ""

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        if !authToken.isEmpty {
            // Fetch user profile to verify token
            APIManager.shared.fetchUserProfile(token: authToken) { [weak self] result in
                switch result {
                case .success(let userProfile):
                    DispatchQueue.main.async {
                        self?.userId = userProfile.id
                        self?.isAuthenticated = true
                    }
                case .failure(_):
                    // Token invalid or other error, clear it
                    KeychainHelper.deleteToken()
                    DispatchQueue.main.async {
                        self?.isAuthenticated = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
    }

    func logout() {
        KeychainHelper.deleteToken()
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.userId = nil
        }
    }
}

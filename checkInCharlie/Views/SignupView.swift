//
//  SignupView.swift
//  checkinCharlie
//
//  Created by Robert Lester on 12/3/24.
//


import SwiftUI

struct SignupView: View {
    // State variables
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var errorMessage: String?

    // Bindings
    @Binding var isAuthenticated: Bool
    @Binding var userId: Int?

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)

            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)

                TextField("Full Name", text: $fullName)

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.numberPad)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                registerUser()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    func registerUser() {
        print("Attempting to register user")

        APIManager.shared.registerUser(
            email: email,
            password: password,
            fullName: fullName,
            phoneNumber: phoneNumber
        ) { result in
            switch result {
            case .success:
                print("Registration successful")
                loginUser(email: email, password: password)
            case .failure(let error):
                print("Registration failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func loginUser(email: String, password: String) {
        APIManager.shared.loginUser(email: email, password: password) { result in
            switch result {
            case .success(let token):
                KeychainHelper.save(token: token)
                APIManager.shared.fetchUserProfile(token: token) { result in
                    switch result {
                    case .success(let userProfile):
                        DispatchQueue.main.async {
                            self.userId = userProfile.id
                            self.isAuthenticated = true
                        }
                    case .failure(let error):
                        print("Failed to fetch user profile: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

import SwiftUI

struct LoginView: View {
    // State variables
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    // Bindings
    @Binding var isAuthenticated: Bool
    @Binding var userId: Int?

    var body: some View {
        NavigationView {
            VStack {
                Text("Login")
                    .font(.largeTitle)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    loginUser()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()

                NavigationLink(destination: SignupView(isAuthenticated: $isAuthenticated, userId: $userId)) {
                    Text("Don't have an account? Sign Up")
                }
                .padding()
            }
            .padding()
        }
    }

    func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        print("Attempting to log in")

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

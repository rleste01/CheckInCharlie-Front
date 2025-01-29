//
//  SendPushView.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//

import SwiftUI

struct SendPushView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedUserID: Int?
    @State private var users: [UserProfile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Users...")
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            fetchUsers()
                        }
                        .padding()
                    }
                } else {
                    List(users, id: \.id, selection: $selectedUserID) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.full_name ?? "No Name")
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Select User", displayMode: .inline)
            .navigationBarItems(trailing: Button("Send") {
                if let userID = selectedUserID,
                   let user = users.first(where: { $0.id == userID }) {
                    sendPush(to: user)
                }
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let token = KeychainHelper.getToken() {
                    fetchUsers()
                } else {
                    self.errorMessage = "User not authenticated."
                }
            }
        }
    }
    
    func fetchUsers() {
        guard let token = KeychainHelper.getToken() else {
            self.errorMessage = "User not authenticated."
            return
        }
        
        isLoading = true
        APIManager.shared.fetchAllUsers(token: token) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedUsers):
                    self.users = fetchedUsers
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func sendPush(to user: UserProfile) {
        print("Sending push to \(user.full_name ?? "Unknown")")
        ProblemManager.shared.hasPendingProblem = true
        ProblemManager.shared.pendingProblem = generateProblem()
    }
    
    func generateProblem() -> ProblemManager.Problem {
        let a = Int.random(in: 1...10)
        let b = Int.random(in: 1...10)
        let question = "What is \(a) + \(b)?"
        let answer = a + b
        return ProblemManager.Problem(question: question, answer: answer)
    }
}

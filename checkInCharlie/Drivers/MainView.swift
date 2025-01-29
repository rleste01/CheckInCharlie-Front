//
//  MainView.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: SessionManager

    @State private var showProblemView = false
    @State private var showContactsView = false
    @State private var showSendPushView = false
    @State private var hasPendingProblem = false
    @State private var showNoProblemAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("CheckInCharlie")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    if hasPendingProblem {
                        showProblemView = true
                    } else {
                        showNoProblemAlert = true
                    }
                }) {
                    Text("Solve Your Problem")
                        .font(.title2)
                }
                .alert(isPresented: $showNoProblemAlert) {
                    Alert(
                        title: Text("No Pending Problem"),
                        message: Text("You don't have any pending problems to solve."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Button(action: {
                    showContactsView = true
                }) {
                    Text("Set Contact Recipients")
                        .font(.title2)
                }

                Button(action: {
                    showSendPushView = true
                }) {
                    Text("Send Push")
                        .font(.title2)
                }

                Button(action: {
                    session.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .onAppear {
                // Check if there's a pending problem
                hasPendingProblem = ProblemManager.shared.hasPendingProblem
            }
            .sheet(isPresented: $showProblemView, onDismiss: {
                hasPendingProblem = ProblemManager.shared.hasPendingProblem
            }) {
                ProblemView()
            }
            .sheet(isPresented: $showContactsView) {
                ContactsView()
            }
            .sheet(isPresented: $showSendPushView) {
                SendPushView()
            }
        }
    }
}

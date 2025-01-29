//
//  ProblemView.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//

import SwiftUI
import MessageUI

struct ProblemView: View {
    @ObservedObject var problemManager = ProblemManager.shared
    @ObservedObject var contactManager = ContactManager.shared
    @State private var userAnswer: String = ""
    @State private var timeRemaining: Int = 30 // Time limit in seconds
    @State private var timer: Timer?
    @State private var showAlert = false
    @State private var showMessageCompose = false
    @State private var contactPhoneNumbers: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            if let problem = problemManager.pendingProblem {
                Text(problem.question)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            } else {
                Text("No problem to solve.")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            }
            
            TextField("Your Answer", text: $userAnswer)
                .keyboardType(.numberPad)
                .padding()
                .border(Color.gray)
                .multilineTextAlignment(.center)
            
            Text("Time Remaining: \(timeRemaining)s")
                .font(.headline)
            
            Button(action: submitAnswer) {
                Text("Submit")
                    .font(.title2)
            }
        }
        .padding()
        .onAppear(perform: startProblem)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Time's Up!"),
                message: Text("A message will be sent to your designated contacts."),
                dismissButton: .default(Text("OK"), action: {
                    // Dismiss the view or reset
                    problemManager.hasPendingProblem = false
                    problemManager.pendingProblem = nil
                })
            )
        }
        .sheet(isPresented: $showMessageCompose) {
            MessageComposeView(
                recipients: contactPhoneNumbers,
                body: "CheckInCharlie Alert: I did not respond in time."
            )
        }
    }
    
    func startProblem() {
        guard problemManager.pendingProblem != nil else { return }
        // Get contact phone numbers from ContactManager
        contactPhoneNumbers = contactManager.contactRecipients.compactMap { $0.phone_number }
        startTimer()
    }
    
    func startTimer() {
        timeRemaining = 30 // Reset the timer to 30 seconds
        timer?.invalidate() // Cancel any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                timer?.invalidate()
                timeUp()
            }
        }
    }
    
    func submitAnswer() {
        timer?.invalidate()
        if let problem = problemManager.pendingProblem, Int(userAnswer) == problem.answer {
            // Correct answer logic
            print("Correct!")
            problemManager.hasPendingProblem = false
            problemManager.pendingProblem = nil
        } else {
            // Incorrect answer logic
            print("Incorrect. Try again.")
            startTimer() // Restart the timer
        }
    }
    
    func timeUp() {
        showAlert = true
        sendSMS()
    }
    
    func sendSMS() {
        if MFMessageComposeViewController.canSendText() {
            showMessageCompose = true
        } else {
            print("SMS services are not available")
        }
    }
}

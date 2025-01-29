//
//  NotificationManager.swift
//  checkInCharlie
//
//  Created by Robert Lester on 10/30/24.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleNotifications(every hours: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Solve this problem!"
        content.body = generateProblem()
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: hours * 3600, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func generateProblem() -> String {
        let a = Int.random(in: 1...10)
        let b = Int.random(in: 1...10)
        return "What is \(a) + \(b)?"
    }
}

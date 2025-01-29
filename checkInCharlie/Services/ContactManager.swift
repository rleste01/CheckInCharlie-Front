//
//  ContactManager.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//

import Foundation

class ContactManager: ObservableObject {
    static let shared = ContactManager()
    
    @Published var contactRecipients: [UserProfile] = []
    
    private let contactsKey = "contactRecipients"
    
    private init() {
        loadContacts()
    }
    
    func saveContacts() {
        if let encoded = try? JSONEncoder().encode(contactRecipients) {
            UserDefaults.standard.set(encoded, forKey: contactsKey)
        }
    }
    
    func loadContacts() {
        if let data = UserDefaults.standard.data(forKey: contactsKey),
           let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) {
            contactRecipients = decoded
        }
    }
    
    func addContact(_ user: UserProfile) {
        if !contactRecipients.contains(where: { $0.id == user.id }) {
            contactRecipients.append(user)
            saveContacts()
        }
    }
    
    func removeContact(_ user: UserProfile) {
        contactRecipients.removeAll { $0.id == user.id }
        saveContacts()
    }
}

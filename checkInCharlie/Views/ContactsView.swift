import SwiftUI

struct ContactsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedUsers = Set<Int>()
    @State private var users: [UserProfile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @ObservedObject private var contactManager = ContactManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Contacts...")
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
                    List(users, id: \.id, selection: $selectedUsers) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.full_name ?? "No Name")
                                    .font(.headline)
                                Text(user.phone_number ?? "No Phone")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if contactManager.contactRecipients.contains(where: { $0.id == user.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleSelection(for: user)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Select Contacts", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                saveSelectedContacts()
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let token = KeychainHelper.getToken() {
                    fetchUsers()
                    loadSelectedContacts()
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
        APIManager.shared.fetchAllUsers(token: token) { result in  // Changed authToken to token
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
    
    func toggleSelection(for user: UserProfile) {
        if selectedUsers.contains(user.id) {
            selectedUsers.remove(user.id)
            contactManager.removeContact(user)
        } else {
            selectedUsers.insert(user.id)
            contactManager.addContact(user)
        }
    }
    
    func saveSelectedContacts() {
        // Contacts are already managed by ContactManager
    }
    
    func loadSelectedContacts() {
        let contacts = contactManager.contactRecipients
        selectedUsers = Set(contacts.map { $0.id })
    }
}

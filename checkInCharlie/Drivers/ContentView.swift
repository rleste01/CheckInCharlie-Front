import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionManager()

    var body: some View {
        Group {
            if session.isAuthenticated {
                MainView()
                    .environmentObject(session)
            } else {
                LoginView(isAuthenticated: $session.isAuthenticated, userId: $session.userId)
            }
        }
        .onAppear {
            session.checkAuthentication()
        }
    }
}

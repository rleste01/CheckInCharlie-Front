//
//  KeychainHelper.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//


import Foundation
import Security

class KeychainHelper {
    static func save(token: String) {
        let tokenData = token.data(using: .utf8)!
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "authToken",
            kSecValueData: tokenData
        ] as CFDictionary
        
        // Delete any existing item
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        if status != errSecSuccess {
            print("Error saving token: \(status)")
        }
    }
    
    // Renamed to match what SendPushView is calling
    static func getToken() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "authToken",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess, let tokenData = dataTypeRef as? Data {
            return String(data: tokenData, encoding: .utf8)
        }
        
        return nil
    }
    
    static func deleteToken() {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "authToken"
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}

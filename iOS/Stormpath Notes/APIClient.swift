//
//  APIClient.swift
//  Stormpath Notes
//
//  Created by Edward Jiang on 2/10/17.
//  Copyright © 2017 Stormpath. All rights reserved.
//

import UIKit
import Stormpath
import AWSDynamoDB

typealias APIClientCallback = (Error?) -> Void

class APIClient {
    static var account: Account?
    static var notes = ""
    
    /**
     Login to Stormpath
     */
    static func login(username: String, password: String, callback: APIClientCallback?) {
        Stormpath.sharedSession.login(username: username, password: password) { (success, error) in
            guard success else {
                callback?(error)
                return
            }
            // Get the AWS Credentials Provider
            let credentialsProvider = AWSServiceManager.default().defaultServiceConfiguration.credentialsProvider as? AppAWSCredentialsProvider
            
            // Allow the AWS Credentials Provider to authenticate with the Stormpath access token & get a user-scoped access token.
            credentialsProvider?.authenticate(accessToken: Stormpath.sharedSession.accessToken!).continueWith { (task) -> Any? in
                // Populate user fields
                Stormpath.sharedSession.me { account, error in
                    self.account = account
                    DispatchQueue.main.async {
                        callback?(error)
                    }
                }
                return nil
            }
        }
    }
    
    // Register a user
    static func register(account: RegistrationForm, callback: APIClientCallback?) {
        Stormpath.sharedSession.register(account: account) { (account, error) in
            callback?(error)
        }
    }
    
    // Get notes for the current user
    static func getNote(callback: APIClientCallback?) {
        guard let account = account else {
            callback?(nil)
            return
        }
        
        // Query DynamoDB for a note with the user's href as the primary key
        AWSDynamoDBObjectMapper.default().load(Note.self, hashKey: account.href.absoluteString, rangeKey: nil)
            .continueWith { task -> Any? in
                
            let dynamoNote = task.result as? Note
            self.notes = dynamoNote?.text ?? "This is your notebook. Edit this to start saving your notes!"
            
            DispatchQueue.main.async {
                callback?(nil)
            }
            
            return nil
        }
    }
    // Save notes for the current user
    static func saveNote(callback: APIClientCallback?) {
        guard let account = account else {
            callback?(nil)
            return
        }
        
        // Create the DynamoDB model
        let note = Note()!
        note.accountHref = account.href.absoluteString
        note.text = notes
        
        // Save to DynamoDB
        AWSDynamoDBObjectMapper.default().save(note)
    }
}

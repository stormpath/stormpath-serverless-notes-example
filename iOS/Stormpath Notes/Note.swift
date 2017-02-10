//
//  Note.swift
//  Stormpath Notes
//
//  Created by Edward Jiang on 2/10/17.
//  Copyright © 2017 Stormpath. All rights reserved.
//

import UIKit
import AWSDynamoDB

// DynamoDB model for the notes.
class Note: AWSDynamoDBObjectModel {
    // Primary key is the account resource
    var accountHref: String?
    
    // Text of the note
    var text: String?
    
    class func dynamoDBTableName() -> String {
        return "stormpath-notes"
    }
    
    class func hashKeyAttribute() -> String {
        return "accountHref"
    }
}

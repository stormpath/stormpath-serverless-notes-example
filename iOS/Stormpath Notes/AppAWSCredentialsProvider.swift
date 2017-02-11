//
//  AppAWSCredentialsProvider.swift
//  Stormpath Notes
//
//  Created by Edward Jiang on 2/10/17.
//  Copyright © 2017 Stormpath. All rights reserved.
//

import UIKit

import UIKit
import AWSCore
import AWSLambda

/**
 The AppAWSCredentialsProvider is our implemention of the `AWSCredentialsProvider` protocol.
 It provides credentials to the AWS client, and is either an unauthenticated set, 
 or authenticated set of credentials.
 */
class AppAWSCredentialsProvider: NSObject, AWSCredentialsProvider {
    /**
     Credentials that allow us to call the stormpath-authorizer Lambda function to get 
     actual user-scoped credentials. Even though this is a key/secret, it's *very* limited
     in access.
     */
    let unauthenticatedCredentials = AWSCredentials(accessKey: "AKIAI2BRME6TDHDWHBEQ", secretKey: "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", sessionKey: nil, expiration: nil)
    
    // Credentials after successful stormpath token exchange
    var authenticatedCredentials: AWSCredentials?
    
    func invalidateCachedTemporaryCredentials() {
        authenticatedCredentials = nil
    }
    
    // Returns the current credentials
    func credentials() -> AWSTask<AWSCredentials> {
        if let credentials = authenticatedCredentials {
            return AWSTask<AWSCredentials>(result: credentials)
        } else {
            return AWSTask<AWSCredentials>(result: unauthenticatedCredentials)
        }
        
    }
    
    // Gets an IAM token via a Stormpath access token
    func authenticate(accessToken: String) -> AWSTask<AnyObject> {
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        return lambdaInvoker.invokeFunction("stormpath-authorizer", jsonObject: ["accessToken": accessToken]).continueWith { (task) -> Any? in
            if let credentialsJSON = (task.result as? [String: Any])?["Credentials"] {
                self.authenticatedCredentials = AWSCredentials(json: credentialsJSON)
            }
            return nil
        }
    }
}

extension AWSCredentials {
    /**
     Helper to decode JSON from the credentials
     */
    convenience init?(json: Any?) {
        if let credentials = json as? [String: String],
            let keyId = credentials["AccessKeyId"],
            let keySecret = credentials["SecretAccessKey"] {
            let sessionToken = credentials["SessionToken"]
            self.init(accessKey: keyId, secretKey: keySecret, sessionKey: sessionToken, expiration: nil)
        } else {
            return nil
        }
    }
}

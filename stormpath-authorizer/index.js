const stormpath = require('stormpath')
const AWS = require('aws-sdk')
const STS = new AWS.STS({apiVersion: '2011-06-15'})

const client = new stormpath.Client()

// Stormpath access token authenticator
var authenticator

exports.myHandler = function(event, context, callback) {
  // Use the authenticator if initialized, otherwise intialize it. 
  if(authenticator) {
    authenticate(event, context, callback)
  } else {
    client.getApplication(process.env.STORMPATH_APPLICATION_HREF, function(err, application) {
      authenticator = new stormpath.StormpathAccessTokenAuthenticator(client).forApplication(application)
      authenticate(event, context, callback)
    })
  }
}

/**
Authenticate a Stormpath access token
 */
var authenticate = function(event, context, callback) {
  authenticator.authenticate(event.accessToken, function (err, authResult) {
    // If it's not valid, callback with an error. 
    if(err) {
      return callback(err)
    }

    // Ask AWS STS to generate temporary credentials limited to the user's href. 
    var params = {
      Policy: JSON.stringify(generatePolicy(authResult.account.href, "arn:aws:dynamodb:us-east-1:569073598720:table/stormpath-notes")), 
      RoleArn: "arn:aws:iam::569073598720:role/stormpath-notes-user", 
      RoleSessionName: "stormpath-token-exchange"
    }
    STS.assumeRole(params, callback)
  })
}

/**
 IAM policy limiting a user to access only their rows in a DynamoDB table
 */
var generatePolicy = function(accountHref, resource) {
  return {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowAccessToOnlyItemsMatchingUserID",
        "Effect": "Allow",
        "Action": [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        "Resource": [
          resource
        ],
        "Condition": {
          "ForAllValues:StringEquals": {
            "dynamodb:LeadingKeys": [
              accountHref
            ]
          }
        }
      }
    ]
  }
}
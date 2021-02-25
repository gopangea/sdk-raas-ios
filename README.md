# SDK-RaaS-iOS

**The following guide explains how to install and implement Pangea RaaS' Mobile SDK into your application environment.** 
- Version number: 1.0.4

## [Changelog](https://github.com/gopangea/sdk-raas-ios/blob/master/CHANGELOG.md)

### Introduction


The Mobile SDK is analogous to [Pangea's Javascript](https://connect-raas-api.pangeamoneytransfer.com/?java#pangea-js-library) code used for fraud review enhancement on the browser and Funding card tokenization.

Pangea requires the use of our SDK to mitigate fraud and to securely collect debit card information for payment. 
Include this library in your ios application using the following instructions.


**To be able to use Pangea RaaS SDK in your application, Pangea must add your hostname to the CORS whitelist.**


### Prerequisites:

iOS 10.0 and above.

### Installation:

**Using CocoaPods:**
  * Add the following line to the Podfile, under your app's target section:
```
pod 'RaaS_SDK', :git => 'https://github.com/gopangea/sdk-raas-ios.git', :tag => 'Version number'
```
  * Run $ pod install in your project directory.
  * Open App.xcworkspace and build.
 
### Implementation:


1. On the top of your ApplicationDelegate add 
```
import RaaS_SDK
```
2. Create the session at the end of applicationDidFinishLaunching:
```
Pangea.sharedInstance.createSession( pangeaSessionID: "NumberSessionHere", debugInfo: true, environment: .INTEGRATION)
```

* createSession() arguments:
  - pangeaSessionID - Unique String identifier of the user's current session in the app. The same identifier is passed by your backend to Pangea.
  - debugInfo - Boolean parameter that enables pangea logging for debugging.
  - environment - Use it to point to the desired environment, there are three: *PRODUCTION*, *DEV* and *INTEGRATION*

  
2. if you need to retrive the session from Pangea instance use the following function:
```
Pangea.sharedInstance.getSessionId()
```

3. When the user's session changes, update the token by calling:
```
Pangea.sharedInstance.updateSessionToken("newToken");
```
4. Notify to pangea on each relevant HTTP request from the app:
```
Pangea.sharedInstance.logRequest("https://<request URL>");
```
5. Collect rich device information. This method should usually be called only once per session:
```
Pangea.sharedInstance.logSensitiveDeviceInfo();
```


### Funding card tokenization:

Pangea RaaS iOS sdk must also be used for generating a temporary token representing a sender’s funding card. Pangea retrieves the token by first encrypting the card data using your public key then sends it to Pangea’s server. You will send the temporary token to your server and finally over to the Pangea RaaS API to create a funding card. Pangea uses the temporary token to generate a permanent token with our card payments provider. The card number and cvv is never stored anywhere in Pangea. You will use the same permanent token for each transfer made with that card. The temporary token is valid for 24 hours. Upon successful generation of the temporary token, you can safely send it to your server. Then to create the funding method in the RaaS API, provide the token along with the other required fields: 

```
Pangea.sharedInstance.createToken(cardInfo: CardInformation, completion: @escaping QueryResult<TokenResponse>) 
```
**The structure of Card information is:**

```
struct CardInformation {
    var publicKey: String
    var partnerIdentifier: String
    var cardNumber: String
    var cvv: String
}
```
* CardInformation() arguments:
  - publicKey - Unique RAS pubic key identifier of provided by Pangea, pass this argument as a String with the key only without any blank/enter/tab/etc space, a valid string could be: 
  
  ```
  "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq7BL3rzZbWx6xDmxDxozfUhoJ2xJawfKoGqBgqUa+ZTWUYUtkrCMuS3l8bKZZij4MQQmFb4vvIUJ0AoY0aVK59uxom1MEA9X89Vaz0Ctv5TNdjm7NQN3oosdtKeMd7g1fAxBXoR2XdShM9Nq0IjNHgWbbgFlq4CTKdPyG7N/M5eAnSjDOO9xIADZ9DsWGk3TgZGKbr36EJGYfT8R1E/l+/2YRLVlKf/lLGkl0LSPJ+kv4icB7i48v2GTTAyRs04oFPc9xB/JdoCxCtUmaIcy
  vsjavj9MxRZ3ubOFLNdh8SJ3GmVgRMndxvJGKAVAeURP4eGFK9btnLan9Kzt6BXcFQIDAQAB"
  ```

  - partnerIdentifier -  This is the name of the shop
  - cardNumber - A valid card number, this number will be encryped and send to the pangea server
  - cvv -  A cvv number, this number will be encryped and send to the pangea server
  
You’ll have a different public key for both sandbox and production. The partnerIdentifier will be the same in both environments and will be assigned to you.

**QueryResult Closure**

This closure will let you retrieve the token from pagea when the service call is completed, it has two parameters
```
typealias QueryResult<T> = (T?, String?) -> Void
```

You can use something similar to this:
  ```
Pangea.sharedInstance.createToken(cardInfo: card, completion: {tokenResponse,error in
                     if let token:TokenResponse = tokenResponse
                     {
                        //do something with your Token
                        print(token.token)
                     }
                     else {
                        // failed operation
                        print(error)
                     }
                     })
```
TokenResponse is just a wrapper for a String

**Client Session Data**

From version 1.0.4 we introduced a new method to get a base64 encoded string which the RaaS partner will store in their database instead of the clientSessionId. This encoded string is a JSON object containing some platform RaaS identifiers and the client session id provided by your implementation.

```
Pangea.sharedInstance.getClientData(completion: @escaping QueryResult<String>) 
```

This id is the same that the sessionID, if you already provided one is not necessary to provide another before calling this method, (when you create your pangea instance you pass this ID as the parameter pangeaSessionID)


You can use something similar to this to retrive your encoded client session data:

```
        Pangea.sharedInstance.getClientData(completion: {clientInfo,error in
                         if let clientInfo:String = clientInfo
                         {
                            //do something with your data encoded string 
                            print(clientInfo)
                         }
                         else {
                            // failed operation
                            print(error)
                         }
                         })
```



### FAQs

Q: Does the SDK require any external frameworks or additional permissions from the user?
* The SDK does not require or prompt for any user permissions.
* The SDK utilizes certain permissions if the host app previously requested them.

Q: When and how should logRequest() be used?
* Call this method every time a user performs a meaningful action inside the flow of the remittance (for
example: start a new remittance , search a contact, finalize the remittance).
* Pangea uses this data for behavioral modeling and analysis, so please take care
to only call logRequest() in response to an actual user action.
* The single URL argument represents the action taken, this can usually be
achieved by passing the same URL used in the backend call for the action (ie.,
https://api.myshop.com/remittance/).

Q: When should logsensitiveDeviceInfo() be called?
* Ideally once per session, depending on the use case. For example - before
attempting to process a remmitance.
* Multiple invocations of this function in a single session will not generate an error,
but have the wasteful effect of generating identical payloads for analysis.

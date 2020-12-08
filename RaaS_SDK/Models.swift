//
//  Models.swift
//  RaaSCardTokenizerIOSExample
//
//  Created by Carlos Hernandez on 22/09/20.
//  Copyright © 2020 Pangea. All rights reserved.
//

import Foundation

public struct CardInformation {
    var publicKey: String
    var partnerIdentifier: String
    var cardNumber: String
    var cvv: String
    public init(
        publicKey: String,
        partnerIdentifier: String,
        cardNumber: String,
        cvv: String){
        self.publicKey = publicKey
        self.partnerIdentifier =  partnerIdentifier
        self.cardNumber  =  cardNumber
        self.cvv =  cvv
    }
}

struct TokenRequest {
    var encryptedCardNumber: String = ""
    var encryptedCvv: String = ""
    var partnerIdentifier: String = ""
    var requestId: String = ""
}

public struct TokenResponse {
    public var token: String
}

internal func getRequestId() -> String{
    let randomNumber = String(drand48()).replacingOccurrences(of:".",with: "")
    let randomNumberString = (randomNumber as NSString).longLongValue
    let requestId = String(randomNumberString, radix: 11)
    return requestId
}
public typealias QueryResult = (TokenResponse?, String?) -> Void

public enum Environment: String {
    case PRODUCTION
    case DEV
    case INTEGRATION
}

internal func getVersion()->String{
    return "1.0.2"
}

internal func getBuild()->String{
    return "4"
}

//
//  Pangea.swift
//  RaaS_SDK
//
//  Created by Carlos Hernandez on 22/09/20.
//  Copyright © 2020 Pangea. All rights reserved.
//

import Foundation



import Foundation
public class Pangea {
    private static let TAG = "Pangea"
    private (set) var debugInfo : Bool = false
    private (set) var pangeaSessionID :String = ""
    public static let sharedInstance = Pangea()
    private (set) var api = "https:api.pangea-raas-integration.com/raas/v1/tokenization/card"
    
    private init() {
    }
    
    public func createSession(pangeaSessionID: String,debugInfo: Bool) {
        RiskifiedBeacon.start("gopangea.com", sessionToken:pangeaSessionID, debugInfo: debugInfo)
        self.debugInfo = debugInfo
        self.pangeaSessionID=pangeaSessionID
    }
    
    
    public func updateSessionToken(newPangeaSessionID: String) {
        pangeaSessionID = newPangeaSessionID
        RiskifiedBeacon.updateSessionToken(newPangeaSessionID)
    }
    
    public func logRequest(url:URL) {
        RiskifiedBeacon.logRequest(url)
    }
    
    public func logSensitiveDeviceInfo() {
        RiskifiedBeacon.logSensitiveDeviceInfo()
    }
    
    public func createToken(cardInfo: CardInformation, completion: @escaping QueryResult) {
        TokenService(api: api).createToken(cardInfo: cardInfo, completion: completion)
    }
    
    
    
}


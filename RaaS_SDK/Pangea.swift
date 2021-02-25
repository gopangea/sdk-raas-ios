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
    private var debugInfo : Bool = false
    private var pangeaSessionID :String = ""
    public static let sharedInstance = Pangea()
    private (set) var api = "https:api.pangea-raas-integration.com/raas/v1/tokenization/card"
    private var environment:Environment = .DEV
    
    private init() {
    }
    
    public func createSession(pangeaSessionID: String,debugInfo: Bool, environment:Environment) {
        RiskifiedBeacon.start("gopangea.com", sessionToken:pangeaSessionID, debugInfo: debugInfo)
        self.debugInfo = debugInfo
        self.pangeaSessionID=pangeaSessionID
        self.environment = environment
    }
    
    public func getSessionId() -> String{
        return self.pangeaSessionID
    }
    
    
    public func updateSessionToken(newPangeaSessionID: String) {
        self.pangeaSessionID = newPangeaSessionID
        RiskifiedBeacon.updateSessionToken(newPangeaSessionID)
    }
    
    public func logRequest(url:URL) {
        RiskifiedBeacon.logRequest(url)
    }
    
    public func logSensitiveDeviceInfo() {
        RiskifiedBeacon.logSensitiveDeviceInfo()
    }
    
    public func createToken(cardInfo: CardInformation, completion: @escaping QueryResult<TokenResponse>) {
        let completionAxiliary:QueryData = {data,error in
            if let error = error {
                let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                completion(nil,errorMessage)
            } else if let data = data{
                let respondMessage = String(decoding: data, as: UTF8.self)
                let tokenResponse = TokenResponse(token:respondMessage)
                if (self.debugInfo) {
                    print(tokenResponse.token)
                }
                completion(tokenResponse,nil)
            }
        }
        RaaSService(environment: environment, debugInfo:debugInfo).createToken(cardInfo: cardInfo, completion: completionAxiliary)
    }
    
    
    
    public func getClientData(completion: @escaping QueryResult<String>) {
        let completionAxiliary:QueryData = {data,error in
            if let error = error {
                let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                completion(nil,errorMessage)
            } else if let data = data{
                do {
                    var json = try JSONSerialization.jsonObject(with: data, options:.mutableContainers) as? [String : Any]
                    json?.merge(["clientSessionId":self.getSessionId()]) {(current,_) in current}
                    if let jsonString = jsonToString(json: json as Any, isDebug: self.debugInfo){
                        let trimmedJsonString = self.getEncodedInfoUser(jsonUserInfo: jsonString)
                        completion(trimmedJsonString, nil)
                    }else{
                        completion(nil, "error when covert json response to string , JSON =  \(String(describing: json?.description))")
                    }
                } catch let error {
                    completion(nil, error.localizedDescription)
                }
            }
        }
        RaaSService(environment: environment, debugInfo:debugInfo).fetchClientInfo(completion: completionAxiliary)
    }
    
    private func getEncodedInfoUser(jsonUserInfo: String) -> String?{
        let trimmedJsonString = jsonUserInfo.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        return trimmedJsonString.base64Encoded()
    }
    
}


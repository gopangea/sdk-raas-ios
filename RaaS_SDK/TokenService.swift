//
//  TokenService.swift
//  RaaSCardTokenizerIOSExample
//
//  Created by Carlos Hernandez on 17/09/20.
//  Copyright © 2020 Pangea. All rights reserved.
//

import Foundation


import Foundation


//MARK: - TokenService


// Runs query data task only
internal class TokenService {
    private let environment :Environment
    private var debugInfo:Bool
    public init(environment: Environment, debugInfo:Bool){
        self.environment = environment
        self.debugInfo = debugInfo
    }
    
    //MARK: - Constants
    private let defaultSession = URLSession(configuration: .default)
    
    //MARK: - Variables And Properties
    
    private var getTokenTask: URLSessionDataTask?
    private var getClientInfoTask: URLSessionDataTask?
    
    //MARK: - Token
    //returns a pair value, if the secon value has an empty screen the response of the fuction is
    //sucessfull but if tot it will return an error message
    private func getTokenAPIBodyObject(cardInfo: CardInformation) -> (body:[String:String], errorMessage:String){
        if !isCardNumberValid(cardNumber: cardInfo.cardNumber){
            return (["":""], "invalid Card Number: \(cardInfo.cardNumber)")
        }
        guard let encryptedCardNumber = RSAUtil.encrypt(string: cardInfo.cardNumber, publicKey: cardInfo.publicKey) else {
            return (["":""], "encryption for card number Failed")
        }
        guard let encryptedCvv = RSAUtil.encrypt(string: cardInfo.cvv, publicKey: cardInfo.publicKey) else {
            return (["":""], "encryption for cvv Failed")
        }
        let body = (["requestId":getRequestId(),
                    "partnerIdentifier":cardInfo.partnerIdentifier,
                    "encryptedCardNumber":encryptedCardNumber,
                    "encryptedCvv":encryptedCvv], "")
        return body
    }
    
    
 
    internal func createToken(cardInfo: CardInformation, completion: @escaping QueryData) {
        getTokenTask?.cancel()
        defer {getTokenTask = nil}
        let bodyObject = getTokenAPIBodyObject(cardInfo: cardInfo)
        if bodyObject.errorMessage != "" {
            completion(nil, MyError(msg: bodyObject.errorMessage))
            return
        }
        let body = bodyObject.body
        if let request = getRequest(path: "v1/tokenization/card", body: body,httpMethod: "POST") {
            getTokenTask = getDataTask(request: request, completion: completion, debugInfo: debugInfo)
            getTokenTask?.resume()
        }else {
            completion(nil,MyError(msg: "error creating the request"))
        }
    }
    
    //    MARK: - Client info
    
    internal func fetchClientInfo(completion: @escaping QueryData) {
        getClientInfoTask?.cancel()
        defer {getClientInfoTask = nil}
        let emptyBody : [String: String]? = nil
        if let request = getRequest(path: "v1/clientSession/data", body: emptyBody,httpMethod: "GET") {
            getClientInfoTask = getDataTask(request: request, completion: completion, debugInfo: debugInfo)
            getClientInfoTask?.resume()
        }else {
            completion(nil,MyError(msg: "error creating the request"))
        }
    }
    
    //    MARK: - General Methods
    private func getDataTask(request: URLRequest, completion: @escaping QueryData, debugInfo: Bool) -> URLSessionDataTask {
        return defaultSession.dataTask(with: request) {data, response, error in
            if debugInfo{
                print("RESPONSE INFO:")
                print("response:  \(String(describing: response))")
                if let data = data{
                    print("Body/data: \(String(decoding: data , as: UTF8.self))")
                }
                print("error: \(String(describing: error))")
            }
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            } else if let data = data{
                DispatchQueue.main.async {
                    completion(data,nil)
                }
            }
        }
    }
    //retuns the simplest base url with the minimn headers required, you have to pass the verb method
    //like "POST", or "GET"
    //path: is the next segment of the url where the resource is located
    //if request doesn't have body pass a nil
    internal func getRequest<T>(path: String,body:T?, httpMethod: String) -> URLRequest?{
        let fullUrl =  ("\(getApi(environment: environment))\(path)")
        if let urlComponents = URLComponents(string: fullUrl) {
            guard let url = urlComponents.url else {
                if(debugInfo){
                    print("url malformed \(String(describing: urlComponents.url))")
                }
                return nil
            }
            let versionNumber = getVersion()
            let buildNumber = getBuild()
            let userAgent = "RaasSdk|iOS|Version=\(versionNumber)|Build=\(buildNumber)"
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") //headers
            request.setValue(userAgent, forHTTPHeaderField: "x-pangea-user-agent")
            request.httpMethod = httpMethod//verb
            var bodyString : String? = nil
            if body != nil {
                let bodyData = try? JSONSerialization.data(withJSONObject: body!)
                request.httpBody = bodyData //adding data
                bodyString = String(decoding: request.httpBody! , as: UTF8.self)
            }
            if(debugInfo){
                print("\(request.httpMethod ?? "") \(String(describing: request.url) )")
                print("BODY \n \(bodyString ?? "")")
                print("HEADERS \n \(String(describing: request.allHTTPHeaderFields) )")
            }
            return request
        }
        return nil
    }
    
    private func getApi(environment: Environment) ->String {
        var api = "noUrlFound"
        switch environment {
        case .PRODUCTION:
            api = "https://api.pangea-raas.com/raas/"
        case .DEV:
            api = "https://api.pangea-raas-dev.com/raas/"
        case .INTEGRATION:
            api = "https:api.pangea-raas-integration.com/raas/"
        }
        return api
    }
    
    
}


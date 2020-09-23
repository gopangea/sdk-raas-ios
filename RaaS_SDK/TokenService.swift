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
public class TokenService {
    private let api :String
    public init(api:String){
        self.api = api
    }
    
    //MARK: - Constants
    private let defaultSession = URLSession(configuration: .default)
    
    //MARK: - Variables And Properties
    
    private var dataTask: URLSessionDataTask?
    
    
    //    MARK: - Internal Methods
    internal func createToken(cardInfo: CardInformation, completion: @escaping QueryResult) {
        dataTask?.cancel()
        if !isCardNumberValid(cardNumber: cardInfo.cardNumber){
            completion(nil,"invalid Card Number: \(cardInfo.cardNumber)")
            return
        }

        guard let encryptedCardNumber = RSAUtil.encrypt(string: cardInfo.cardNumber, publicKey: cardInfo.publicKey) else {
           completion(nil,"encryption for card number Failed")
           return
        }
        guard let encryptedCvv = RSAUtil.encrypt(string: cardInfo.cvv, publicKey: cardInfo.publicKey) else {
           completion(nil,"encryption for cvv Failed")
           return
        }

        if let urlComponents = URLComponents(string: api) {
        
            guard let url = urlComponents.url else {
                print("url malformed \(String(describing: urlComponents.url))")
                return
            }
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") //headers
            request.httpMethod = "POST"//verb

            let body = ["requestId":getRequestId(),
                        "partnerIdentifier":cardInfo.partnerIdentifier,
                        "encryptedCardNumber":encryptedCardNumber,
                        "encryptedCvv":encryptedCvv]
            let bodyData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = bodyData //adding data
            
            dataTask = defaultSession.dataTask(with: request) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                if let error = error {
                    let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
                    DispatchQueue.main.async {
                        completion(nil,errorMessage)
                    }
                } else if let data = data{
                    let respondMessage = String(decoding: data, as: UTF8.self)
                    let tokenResponse = TokenResponse(token:respondMessage)
                    print(tokenResponse.token)
                    DispatchQueue.main.async {
                        completion(tokenResponse,nil)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func cancel() {
        dataTask?.cancel()
    }
    
    
}

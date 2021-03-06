//
//  RSAUtil.swift
//  RaaSCardTokenizerIOSExample
//
//  Created by Carlos Hernandez on 17/09/20.
//  Copyright © 2020 Pangea. All rights reserved.
//

import Foundation

internal class RSAUtil {
    static func encrypt(string: String, publicKey: String?) -> String? {
        guard let publicKey = publicKey else { return nil }

        let keyString = publicKey.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "").replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
        guard let data = Data(base64Encoded: keyString) else { return nil }

        var attributes: CFDictionary {
            return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits   : 2048,
                    kSecReturnPersistentRef : kCFBooleanTrue!] as CFDictionary
        }

        var error: Unmanaged<CFError>? = nil
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            print(error.debugDescription)
            return nil
        }
        return _encrypt(string: string, publicKey: secKey)
    }

    static private func _encrypt(string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)

        var keySize   = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        // Encrypto  should less than key length
        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return nil }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}

extension String {
    //"heroes".base64Encoded() // It will return: aGVyb2Vz
    //"aGVyb2Vz".base64Decoded() // It will return: heroes
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

internal func jsonToString(json: Any, isDebug: Bool) -> String?{
    do {
        // first of all convert json to the data
        let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        // the data will be converted to the string
        let convertedString = String(data: data1, encoding: String.Encoding.utf8)
        return convertedString
    } catch let myJSONError {
        if isDebug {
            print(myJSONError)
        }
        return nil
    }
    
}




 

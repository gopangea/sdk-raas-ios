//
//  CardUtils.swift
//  RaaSCardTokenizerIOSExample
//
//  Created by Carlos Hernandez on 22/09/20.
//  Copyright © 2020 Pangea. All rights reserved.
//

import Foundation


internal func isCardNumberValid(cardNumber: String)->Bool{
    var card = cardNumber
    card.removingRegexMatches(pattern: "\\D+", replaceWith: "")
    var numbers = card.map { character in
        Int(String(character))
    }
    numbers.reverse()
    if (numbers.count < 12) {
        return false
    }
    var total = 0
    for (index, element) in numbers.enumerated() {
        if element != nil{
            if (index % 2 != 0){
                if (numbers[index]! > 4){
                    total += 2 * numbers[index]! - 9
                }else{
                    total += 2 * numbers[index]! - 0
                }
            }else{
                 total += numbers[index]!
            }
        }else{
            //conversion error, this cannot happen because we are filtering  only numbers and the conversion should happen all the times
            return false
        }
    }
    return total % 10 == 0
}

// http://www.ietf.org/rfc/rfc4122.txt
internal func createUUID()-> String {
    var s = [Character](repeating: " ", count: 36)
    let hexDigits = Array("0123456789abcdef")
    for (index, _) in s.enumerated() {
        let r = Int(arc4random_uniform(16)) ;
        s[index] = hexDigits[r]
       }
    s[4] = "4"
    var temporalNumber = s[19].hexDigitValue
    if containsMatch(of: "\\D+", inString: String(s[19])) {
        temporalNumber = 0x0
    }
    temporalNumber = ((temporalNumber! & 3)|8)
    s[19] = String(temporalNumber!, radix: 16).first! //s[19] can be only 8,9,a or b
    s[8] = "-"; s[13] = "-";s[18] = "-"; s[23] = "-"
    return String(s)
}

internal extension String {
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return
        }
    }
}



internal func containsMatch(of pattern: String, inString string: String) -> Bool {
  guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
    return false
  }
  let range = NSRange(string.startIndex..., in: string)
  return regex.firstMatch(in: string, options: [], range: range) != nil
}

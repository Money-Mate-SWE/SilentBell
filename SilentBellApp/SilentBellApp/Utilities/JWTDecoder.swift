//
//  JWTDecoder.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 10/6/25.
//

import Foundation

struct JWTDecoder {
    static func decode(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }
        
        var base64String = String(segments[1])
        // Add padding if needed
        let requiredLength = (4 - base64String.count % 4) % 4
        if requiredLength > 0 {
            base64String += String(repeating: "=", count: requiredLength)
        }
        base64String = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64String),
              let json = try? JSONSerialization.jsonObject(with: data),
              let payload = json as? [String: Any] else {
            return nil
        }

        return payload
    }
}

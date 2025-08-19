//
//  Models.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import Foundation

struct ClaimData: Codable {
    let version: Int
    let claimId: String
    let secret: String
    let token: String
    let amount: Double
    
    enum CodingKeys: String, CodingKey {
        case version = "v"
        case claimId
        case secret
        case token
        case amount
    }
}

enum AppMode {
    case initial
    case sender
    case receiver
    case claiming
    case success
}

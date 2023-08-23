//
//  Token.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 10/08/2023.
//


import Foundation

struct Token {
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}

// MARK: - Decodable
extension Token: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
    }
}

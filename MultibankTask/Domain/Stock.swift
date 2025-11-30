//
//  Stock.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation

enum PriceChange: Codable {
    case increased
    case decreased
    case unchanged
}

struct Stock {
    let ticker: String
    let name: String
    let price: Decimal
    let priceChange: PriceChange
    let description: String?
}

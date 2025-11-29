//
//  StockAPI.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation

enum PriceChangeDTO: String, Codable {
    case increased
    case decreased
    case unchanged
}

struct StockDTO: Codable {
    let ticker: String
    let name: String
    let price: Decimal
    let priceChange: PriceChangeDTO
}

protocol StockAPI: Sendable {
    func stocks() -> WebSocketTask<StockDTO, StockDTO>
}

final class StockAPIImpl: StockAPI {
    
    func stocks() -> WebSocketTask<StockDTO, StockDTO> {
        WebSocketTask(url: URL(string: "wss://ws.postman-echo.com/raw")!)
    }
}

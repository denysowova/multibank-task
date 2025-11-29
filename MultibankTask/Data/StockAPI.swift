//
//  StockAPI.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation

struct StockDTO: Codable {
    let ticker: String
    let name: String
    let price: Decimal
}

protocol StockAPI: Sendable {
    func stocks() -> WebSocketTask<StockDTO, StockDTO>
}

final class StockAPIImpl: StockAPI {
    
    func stocks() -> WebSocketTask<StockDTO, StockDTO> {
        WebSocketTask(url: URL(string: "wss://ws.postman-echo.com/raw")!)
    }
}

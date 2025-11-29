//
//  StockStreamer.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
import Combine

final class StockStreamer: Sendable {
    
    private let task: WebSocketTask<StockDTO, StockDTO>
    
    var stock: AnyPublisher<Stock, StockError> {
        task.messages
            .map {
                Stock(ticker: $0.ticker, name: $0.name, price: $0.price)
            }
            .mapError { error in
                StockError(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    init(task: WebSocketTask<StockDTO, StockDTO>) {
        self.task = task
    }
    
    func start() throws {
        try task.start()
    }
    
    func update(_ stock: Stock) async throws {
        let dto = StockDTO(ticker: stock.ticker, name: stock.name, price: stock.price)
        try await task.sendMessage(dto)
    }
}

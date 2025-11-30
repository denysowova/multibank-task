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
                Stock(
                    ticker: $0.ticker,
                    name: $0.name,
                    price: $0.price,
                    priceChange: PriceChange(from: $0.priceChange),
                    description: nil
                )
            }
            .mapError { error in
                StockError.networking(error)
            }
            .eraseToAnyPublisher()
    }
    
    init(task: WebSocketTask<StockDTO, StockDTO>) {
        self.task = task
    }
    
    func start() throws {
        try task.start()
    }
    
    func terminate() {
        task.terminate()
    }
    
    func update(_ stock: Stock) async throws {
        let dto = StockDTO(
            ticker: stock.ticker,
            name: stock.name,
            price: stock.price,
            priceChange: stock.priceChange.toDTO()
        )
        try await task.sendMessage(dto)
    }
}

private extension PriceChange {
    
    init(from dto: PriceChangeDTO) {
        switch dto {
        case .increased:
            self = .increased
        case .decreased:
            self = .decreased
        case .unchanged:
            self = .unchanged
        }
    }
    
    func toDTO() -> PriceChangeDTO {
        return switch self {
        case .increased:
                .increased
        case .decreased:
                .decreased
        case .unchanged:
                .unchanged
        }
    }
}

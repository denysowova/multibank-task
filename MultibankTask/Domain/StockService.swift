//
//  StockService.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
@preconcurrency import Combine

protocol StockService {
    var stocks: AnyPublisher<[Stock], Error> { get }
}

final class StockServiceImpl: StockService, Sendable {
    
    private let repository: StockRepository
    private let streamer: StockStreamer
    
    private nonisolated(unsafe) var cancellables: Set<AnyCancellable> = []
    
    private let _stocks: CurrentValueSubject<[Stock], Error>
    
    var stocks: AnyPublisher<[Stock], Error> {
        _stocks.eraseToAnyPublisher()
    }
    
    init(repository: StockRepository) {
        self.repository = repository
        streamer = repository.streamer()
        _stocks = CurrentValueSubject(repository.stocks())
        
        observeStocks()
        startTimer()
    }
    
    private func observeStocks() {
        streamer.stock
            .collect(.byTime(DispatchQueue.main, .seconds(2))) // blocks main!!
            .sink(
                receiveCompletion: { completion in
                    print("completed stock stream: \(completion)")
                },
                receiveValue: { stocks in
//                    print("updated: \(stock.name): \(stock.price)")
                    self._stocks.value = stocks
                }
            )
            .store(in: &cancellables)
        
        do {
            try streamer.start()
        } catch {
            print("Error starting streamer: \(error.localizedDescription)")
        }
    }
    
    private func startTimer() {
        Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                self._stocks.value.forEach {
                    let priceUpdate = Double.random(in: -0.05...0.05)
                    let update = Stock(ticker: $0.ticker, name: $0.name, price: $0.price + Decimal(priceUpdate))
                    Task {
                        do {
                            print("Updating stock: \(update.name) with new price: \(update.price)")
                            try await self.streamer.update(update)
                        } catch {
                            print("error sending update: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}

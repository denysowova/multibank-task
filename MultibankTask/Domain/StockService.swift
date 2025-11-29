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
    private nonisolated(unsafe) var stocksCache: [String: Stock]
    
    private let _stocks: CurrentValueSubject<[Stock], Error>
    
    var stocks: AnyPublisher<[Stock], Error> {
        _stocks.eraseToAnyPublisher()
    }
    
    init(repository: StockRepository) {
        self.repository = repository
        streamer = repository.streamer()
        
        let initialStocks = repository.stocks().sorted { $0.price > $1.price }
        stocksCache = Dictionary(uniqueKeysWithValues: initialStocks.map { ($0.ticker, $0) })
        _stocks = CurrentValueSubject(initialStocks)
        
        observeStocks()
        startTimer()
    }
    
    private func observeStocks() {
        streamer.stock
            .sink(
                receiveCompletion: { completion in
                    print("completed stock stream: \(completion)")
                },
                receiveValue: { stock in
//                    print("updated: \(stock.name): \(stock.price)")
                    self.stocksCache[stock.ticker] = stock
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
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // 1. cache and publish stocks here! use a set instead!
                // 2. or use flatmap to observe new stocks after updates are sent, but sequential and therefore not good
                // 3. combine 2 publishers in a way it fires every time one of them changes but we need to know which one has changed
                
                self._stocks.value = self.stocksCache.values.sorted { $0.price > $1.price }
                self.sendStockUpdates()
            }
            .store(in: &cancellables)
    }
    
    private func sendStockUpdates() {
        // Pick 10 random stocks to be "active movers" this cycle
        let activeMovers = Set(Array(stocksCache.keys).shuffled().prefix(10))

        _stocks.value.forEach { stock in
            // Active movers get +/-40% volatility, others get +/-5%
            let volatility = activeMovers.contains(stock.ticker) ? 0.40 : 0.03
            let priceChangePercent = Double.random(in: -volatility...volatility)

            let priceChangeAmount = stock.price * Decimal(priceChangePercent)
            let newPrice = stock.price + priceChangeAmount

            let priceChange: PriceChange
            
            if priceChangePercent > 0 {
                priceChange = .increased
            } else if priceChangePercent < 0 {
                priceChange = .decreased
            } else {
                priceChange = .unchanged
            }

            let update = Stock(
                ticker: stock.ticker,
                name: stock.name,
                price: newPrice,
                priceChange: priceChange
            )

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
}

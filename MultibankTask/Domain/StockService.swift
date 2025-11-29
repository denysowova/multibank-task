//
//  StockService.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
@preconcurrency import Combine

protocol StockService {
    func startStreaming() -> AnyPublisher<[Stock], Error>
    func stopStreaming()
    func stock(for ticker: String) -> AnyPublisher<Stock, Error>
}

final class StockServiceImpl: StockService, @unchecked Sendable {
    
    private let repository: StockRepository
    private let streamer: StockStreamer
    
    private var stocksCache: [String: Stock]
    private var stocks: CurrentValueSubject<[Stock], Error>?
    private var timerCancellable: AnyCancellable?
    private var stocksCancellable: AnyCancellable?
    
    init(repository: StockRepository) {
        self.repository = repository
        streamer = repository.streamer()
        stocksCache = Dictionary(uniqueKeysWithValues: repository.stocks().map { ($0.ticker, $0) })
    }
    
    func startStreaming() -> AnyPublisher<[Stock], Error> {
        if let stocks {
            return stocks.eraseToAnyPublisher()
        }
        
        let cachedStocks = stocksCache.values.sorted { $0.price > $1.price }
        let stocksSubject = CurrentValueSubject<[Stock], Error>(cachedStocks)
        self.stocks = stocksSubject
        
        observeStocks()
        startTimer()
        
        return stocksSubject.eraseToAnyPublisher()
    }
    
    private func terminate(with completion: Subscribers.Completion<Error>) {
        stocks?.send(completion: completion)
        stocks = nil
        
        timerCancellable?.cancel()
        timerCancellable = nil
        
        stocksCancellable?.cancel()
        stocksCancellable = nil
    }
    
    func stopStreaming() {
        terminate(with: .finished)
    }
    
    func stock(for ticker: String) -> AnyPublisher<Stock, Error> {
        startStreaming()
            .compactMap { stocks in
                stocks.first(where: { $0.ticker == ticker })
            }
            .eraseToAnyPublisher()
    }
    
    private func observeStocks() {
        stocksCancellable = streamer.stock
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
//                        self.stocks?.send(completion: .finished)
                        self.terminate(with: .finished)
                    case .failure(let error):
//                        self.stocks?.send(completion: .failure(error))
                        self.terminate(with: .failure(error))
                    }
                },
                receiveValue: { stock in
                    self.stocksCache[stock.ticker] = stock
                }
            )
        
        do {
            try streamer.start()
        } catch {
            terminate(with: .failure(error))
        }
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // 1. cache and publish stocks here! use a set instead!
                // 2. or use flatmap to observe new stocks after updates are sent, but sequential and therefore not good
                // 3. combine 2 publishers in a way it fires every time one of them changes but we need to know which one has changed
                
                self.stocks?.value = self.stocksCache.values.sorted { $0.price > $1.price }
                self.sendStockUpdates()
            }
    }
    
    private func sendStockUpdates() {
        // Pick 10 random stocks to be "active movers" this cycle
        let activeMovers = Set(Array(stocksCache.keys).shuffled().prefix(10))

        stocksCache.values.forEach { stock in
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
//                    print("Updating stock: \(update.name) with new price: \(update.price)")
                    try await self.streamer.update(update)
                } catch {
                    print("error sending update: \(error.localizedDescription)")
                }
            }
        }
    }
}

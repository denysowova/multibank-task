//
//  StockService.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
@preconcurrency import Combine

protocol StockService {
    var isUpdating: AnyPublisher<Bool, Never> { get }
    
    func stocks() -> AnyPublisher<[Stock], StockError>
    func stock(for ticker: String) -> AnyPublisher<Stock, StockError>
    func resume()
    func pause()
}

/// NOTE: @unchecked Sendable is solvable by wrapping state in a mutex. See the safe-service branch
final class StockServiceImpl: StockService, @unchecked Sendable {
    
    private let repository: StockRepository
    
    private var streamer: StockStreamer?
    private var stocksCache: [String: Stock]
    private var stocksSubject: CurrentValueSubject<[Stock], StockError>?
    
    private var timerCancellable: AnyCancellable?
    private var stocksCancellable: AnyCancellable?
    
    private var isUpdatingSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isUpdating: AnyPublisher<Bool, Never> {
        isUpdatingSubject.eraseToAnyPublisher()
    }
    
    init(repository: StockRepository) {
        self.repository = repository
        stocksCache = Dictionary(uniqueKeysWithValues: repository.stocks().map { ($0.ticker, $0) })
    }
    
    func stocks() -> AnyPublisher<[Stock], StockError> {
        if let stocksSubject {
            return stocksSubject.eraseToAnyPublisher()
        }
        
        isUpdatingSubject.value = true
        
        let cachedStocks = stocksCache.values.sorted { $0.price > $1.price }
        let stocksSubject = CurrentValueSubject<[Stock], StockError>(cachedStocks)
        self.stocksSubject = stocksSubject
        
        observeStocks()
        startTimer()
        
        return stocksSubject.eraseToAnyPublisher()
    }
    
    private func terminate(with completion: Subscribers.Completion<StockError>) {
        stocksSubject?.send(completion: completion)
        stocksSubject = nil
        
        timerCancellable?.cancel()
        timerCancellable = nil
        
        stocksCancellable?.cancel()
        stocksCancellable = nil
        
        Task {
            try await streamer?.terminate()
        }
        
        isUpdatingSubject.value = false
    }
    
    func stock(for ticker: String) -> AnyPublisher<Stock, StockError> {
        stocks()
            .flatMap { stocks in
                if let stock = stocks.first(where: { $0.ticker == ticker }) {
                    Just<Stock>(stock).setFailureType(to: StockError.self).eraseToAnyPublisher()
                } else {
                    Fail<Stock, StockError>(error: StockError.notFound).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func resume() {
        if stocksSubject != nil {
            isUpdatingSubject.value = true
        }
    }
    
    func pause() {
        isUpdatingSubject.value = false
    }
    
    private func observeStocks() {
        streamer = repository.streamer()
        
        stocksCancellable = streamer?.stock
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.terminate(with: .finished)
                    case .failure(let error):
                        self?.terminate(with: .failure(error))
                    }
                },
                receiveValue: { [weak self] stock in
                    guard let self else {
                        return
                    }

                    let description = self.repository.description(for: stock.ticker)
                    
                    self.stocksCache[stock.ticker] = Stock(
                        ticker: stock.ticker,
                        name: stock.name,
                        price: stock.price,
                        priceChange: stock.priceChange,
                        description: description
                    )
                }
            )
        
        Task {
            do {
                try await streamer?.start()
            } catch {
                terminate(with: .failure(StockError.networking(error)))
            }
        }
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .prepend(.now)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                
                if self.isUpdatingSubject.value {
                    self.stocksSubject?.value = self.stocksCache.values.sorted { $0.price > $1.price }
                }
                
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
                priceChange: priceChange,
                description: nil
            )

            Task {
                do {
                    try await self.streamer?.update(update)
                } catch {
                    print("Error sending update: \(error.localizedDescription)")
                }
            }
        }
    }
}

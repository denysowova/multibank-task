//
//  StockService.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
import Synchronization
@preconcurrency import Combine

protocol StockService {
    var isUpdating: AnyPublisher<Bool, Never> { get }
    
    func stocks() -> AnyPublisher<[Stock], StockError>
    func stock(for ticker: String) -> AnyPublisher<Stock, StockError>
    func resume()
    func pause()
}

final class StockServiceImpl: StockService, Sendable {
    
    private class StockState {
        var streamer: StockStreamer?
        var cache: [String: Stock]
        var stocks: CurrentValueSubject<[Stock], StockError>?
        
        init(
            streamer: StockStreamer? = nil,
            cache: [String: Stock] = [:],
            stocks: CurrentValueSubject<[Stock], StockError>? = nil
        ) {
            self.streamer = streamer
            self.cache = cache
            self.stocks = stocks
        }
    }
    
    private let repository: StockRepository
    private let stockState = Mutex(StockState())
    
    private nonisolated(unsafe) var timerCancellable: AnyCancellable?
    private nonisolated(unsafe) var stocksCancellable: AnyCancellable?
    
    private let isUpdatingSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isUpdating: AnyPublisher<Bool, Never> {
        isUpdatingSubject.eraseToAnyPublisher()
    }
    
    init(repository: StockRepository) {
        self.repository = repository
        
        stockState.withLock {
            $0.cache = Dictionary(uniqueKeysWithValues: repository.stocks().map { ($0.ticker, $0) })
        }
    }
    
    func stocks() -> AnyPublisher<[Stock], StockError> {
        if let stocksSubject = stockState.withLock({ $0.stocks }) {
            return stocksSubject.eraseToAnyPublisher()
        }

        isUpdatingSubject.value = true

        let stocksSubject = stockState.withLock {
            let cachedStocks = $0.cache.values.sorted { $0.price > $1.price }
            let stocksSubject = CurrentValueSubject<[Stock], StockError>(cachedStocks)
            $0.stocks = stocksSubject
            return stocksSubject
        }

        observeStocks()
        startTimer()

        return stocksSubject.eraseToAnyPublisher()
    }
    
    private func terminate(with completion: Subscribers.Completion<StockError>) {
        stockState.withLock {
            $0.stocks?.send(completion: completion)
            $0.stocks = nil
        }

        timerCancellable?.cancel()
        timerCancellable = nil

        stocksCancellable?.cancel()
        stocksCancellable = nil

        Task {
            await stockState.withLock { $0.streamer }?.terminate()
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
        stockState.withLock {
            if $0.stocks != nil {
                isUpdatingSubject.value = true
            }
        }
    }
    
    func pause() {
        isUpdatingSubject.value = false
    }
    
    private func observeStocks() {
        let streamer = repository.streamer()
        stockState.withLock { $0.streamer = streamer }

        stocksCancellable = streamer.stock
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

                    self.stockState.withLock {
                        $0.cache[stock.ticker] = Stock(
                            ticker: stock.ticker,
                            name: stock.name,
                            price: stock.price,
                            priceChange: stock.priceChange,
                            description: description
                        )
                    }
                }
            )

        Task {
            do {
                try await streamer.start()
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
                    self.stockState.withLock {
                        $0.stocks?.value = $0.cache.values.sorted { $0.price > $1.price }
                    }
                }

                self.sendStockUpdates()
            }
    }
    
    private func sendStockUpdates() {
        let (activeMovers, stocks, streamer) = stockState.withLock { state in
            // Pick 10 random stocks to be "active movers" this cycle
            let activeMovers = Set(Array(state.cache.keys).shuffled().prefix(10))
            return (activeMovers, Array(state.cache.values), state.streamer)
        }

        stocks.forEach { stock in
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
                    try await streamer?.update(update)
                } catch {
                    print("Error sending update: \(error.localizedDescription)")
                }
            }
        }
    }
}

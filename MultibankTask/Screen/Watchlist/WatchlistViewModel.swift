//
//  WatchlistViewModel.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 28.11.25.
//

import Foundation
import Combine

struct WatchlistItem: Identifiable {
    let id: String
    let ticker: String
    let name: String
    let price: String
    let priceChange: PriceChange
}

@MainActor
final class WatchlistViewModel: ObservableObject {
    
    private let service: StockService
    
    private var stocksCancellable: AnyCancellable?
    private var pausedCancellable: AnyCancellable?
    
    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    @Published private(set) var items: [WatchlistItem] = []
    @Published private(set) var isConnected = false
    @Published private(set) var isUpdating = true
    @Published var error: Error?
    
    init(service: StockService) {
        self.service = service
        
        observeUpdatingStatus()
        observeStocks()
    }
    
    func toggleStreaming() {
        if isUpdating {
            service.pause()
        } else {
            service.resume()
        }
    }
    
    private func observeStocks() {
        stocksCancellable?.cancel()
        stocksCancellable = nil
        
        isConnected = true
        
        stocksCancellable = service.stocks()
            .map { stocks in
                stocks.map {
                    let priceString = self.priceFormatter.string(from: $0.price as NSDecimalNumber) ?? "\($0.price)"

                    return WatchlistItem(
                        id: $0.ticker,
                        ticker: $0.ticker,
                        name: $0.name,
                        price: "$\(priceString)",
                        priceChange: $0.priceChange
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        self.error = error
                    }
                    self.isConnected = false
                },
                receiveValue: { items in
                    self.items = items
                }
            )
    }
    
    private func observeUpdatingStatus() {
        pausedCancellable = service.isUpdating
            .receive(on: DispatchQueue.main)
            .assign(to: \.self.isUpdating, on: self)
    }
}

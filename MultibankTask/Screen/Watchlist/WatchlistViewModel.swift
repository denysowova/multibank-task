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
    
    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    @Published private(set) var items: [WatchlistItem] = []
    
    init(service: StockService) {
        self.service = service
        
        observeStocks()
    }
    
    private func observeStocks() {
        

        stocksCancellable = service.stocks
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
                    print("xxx stopped watchlist: \(completion)")
                },
                receiveValue: { items in
                    self.items = items
                }
            )
    }
}

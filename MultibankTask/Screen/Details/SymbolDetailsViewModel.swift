//
//  SymbolDetailsViewModel.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
import Combine

struct StockDetailItem {
    let ticker: String
    let companyName: String
    let description: String
    let price: String
    let priceChange: PriceChange
}

@MainActor
final class SymbolDetailsViewModel: ObservableObject {

    private let stockService: StockService
    private let ticker: String

    private var stockCancellable: AnyCancellable?

    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    @Published private(set) var state: StockDetailItem?
    @Published var error: Error?

    init(stockService: StockService, ticker: String) {
        self.stockService = stockService
        self.ticker = ticker
    }
    
    func performTasks() {
        observeStock()
    }

    private func observeStock() {
        stockCancellable = stockService.stock(for: ticker)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] stock in
                    guard let self else { return }

                    let priceString = self.priceFormatter.string(from: stock.price as NSDecimalNumber) ?? "\(stock.price)"

                    self.state = StockDetailItem(
                        ticker: stock.ticker,
                        companyName: stock.name,
                        description: stock.description ?? "No description available",
                        price: "$\(priceString)",
                        priceChange: stock.priceChange
                    )
                }
            )
    }
}

//
//  SymbolDetailsViewModel.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
import Combine

@MainActor
final class SymbolDetailsViewModel: ObservableObject {

    private let stockService: StockService

    private var stockCancellable: AnyCancellable?

    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    @Published private(set) var ticker: String
    @Published private(set) var companyName = ""
    @Published private(set) var price = ""
    @Published private(set) var priceChange: PriceChange = .unchanged
    @Published private(set) var description = ""
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
                    let priceString = self?.priceFormatter.string(from: stock.price as NSDecimalNumber) ?? "\(stock.price)"
                    self?.companyName = stock.name
                    self?.price = "$\(priceString)"
                    self?.priceChange = stock.priceChange
                    self?.description = "Stock details"
                }
            )
    }
}

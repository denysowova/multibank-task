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

    init(stockService: StockService, ticker: String) {
        self.stockService = stockService
        self.ticker = ticker

        observeStock()
    }

    private func observeStock() {
        stockCancellable = stockService.stock(for: ticker)
            .sink(
                receiveCompletion: { completion in
                    print("Completed stock details stream: \(completion)")
                },
                receiveValue: { [weak self] stock in
                    guard let self else {
                        return
                    }

                    let priceString = self.priceFormatter.string(from: stock.price as NSDecimalNumber) ?? "\(stock.price)"

                    self.companyName = stock.name
                    self.price = "$\(priceString)"
                    self.priceChange = stock.priceChange
                    self.description = "Stock details"
                }
            )
    }
}

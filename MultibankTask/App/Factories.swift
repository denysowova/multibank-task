//
//  Factories.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation

@MainActor
private enum DataFactory {
    static let stockAPI: StockAPI = StockAPIImpl()
    static let stockRepository: StockRepository = StockRepositoryImpl(api: DataFactory.stockAPI)
}

@MainActor
private enum DomainFactory {
    static let stockService: StockService = StockServiceImpl(repository: DataFactory.stockRepository)
}

@MainActor
enum ViewModelFactory {
    
    static func feed() -> FeedViewModel {
        FeedViewModel(service: DomainFactory.stockService)
    }
    
    static func symbolDetails(withTicker ticker: String) -> SymbolDetailsViewModel {
        SymbolDetailsViewModel(stockService: DomainFactory.stockService, ticker: ticker)
    }
}

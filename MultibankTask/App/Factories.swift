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
    
    static func feedViewModel() -> WatchlistViewModel {
        WatchlistViewModel(service: DomainFactory.stockService)
    }
    
    static func symbolDetailsViewModel(withTicker ticker: String) -> SymbolDetailsViewModel {
        SymbolDetailsViewModel(ticker: ticker)
    }
}

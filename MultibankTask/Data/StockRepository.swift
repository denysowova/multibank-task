//
//  StockRepository.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation
import Combine

protocol StockRepository: Sendable {
    func streamer() -> StockStreamer
    func stocks() -> [Stock]
}

final class StockRepositoryImpl: StockRepository {
    
    private let api: StockAPI
    
    init(api: StockAPI) {
        self.api = api
    }
    
    func streamer() -> StockStreamer {
        let task = api.stocks()
        return StockStreamer(task: task)
    }
    
    func stocks() -> [Stock] {
        [
            Stock(ticker: "AAPL", name: "Apple Inc.", price: 189.95),
            Stock(ticker: "MSFT", name: "Microsoft Corporation", price: 374.85),
            Stock(ticker: "GOOGL", name: "Alphabet Inc.", price: 140.35),
            Stock(ticker: "AMZN", name: "Amazon.com Inc.", price: 151.75),
            Stock(ticker: "META", name: "Meta Platforms Inc.", price: 328.45),
            Stock(ticker: "TSLA", name: "Tesla Inc.", price: 242.80),
            Stock(ticker: "NVDA", name: "NVIDIA Corporation", price: 495.22),
            Stock(ticker: "JPM", name: "JPMorgan Chase & Co.", price: 158.30),
            Stock(ticker: "V", name: "Visa Inc.", price: 267.90),
            Stock(ticker: "JNJ", name: "Johnson & Johnson", price: 159.45),
            Stock(ticker: "WMT", name: "Walmart Inc.", price: 163.72),
            Stock(ticker: "PG", name: "Procter & Gamble Co.", price: 163.50),
            Stock(ticker: "MA", name: "Mastercard Inc.", price: 425.18),
            Stock(ticker: "UNH", name: "UnitedHealth Group Inc.", price: 520.65),
            Stock(ticker: "HD", name: "The Home Depot Inc.", price: 385.40),
            Stock(ticker: "DIS", name: "The Walt Disney Company", price: 95.30),
            Stock(ticker: "BAC", name: "Bank of America Corp.", price: 38.75),
            Stock(ticker: "NFLX", name: "Netflix Inc.", price: 485.60),
            Stock(ticker: "ADBE", name: "Adobe Inc.", price: 498.20),
            Stock(ticker: "CRM", name: "Salesforce Inc.", price: 265.85),
            Stock(ticker: "CSCO", name: "Cisco Systems Inc.", price: 52.45),
            Stock(ticker: "PEP", name: "PepsiCo Inc.", price: 172.30),
            Stock(ticker: "KO", name: "The Coca-Cola Company", price: 63.25),
            Stock(ticker: "INTC", name: "Intel Corporation", price: 24.15),
            Stock(ticker: "NKE", name: "Nike Inc.", price: 78.90)
        ]
    }
}

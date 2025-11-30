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
    func description(for ticker: String) -> String?
}

final class StockRepositoryImpl: StockRepository {

    private let api: StockAPI

    private let descriptions: [String: String] = [
        "AAPL": "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.",
        "MSFT": "Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide.",
        "GOOGL": "Alphabet Inc. provides various products and services worldwide, including Google Search, advertising, cloud computing, and hardware products.",
        "AMZN": "Amazon.com Inc. engages in the retail sale of consumer products and subscriptions through online and physical stores.",
        "META": "Meta Platforms Inc. engages in the development of social technology and metaverse products connecting people worldwide.",
        "TSLA": "Tesla Inc. designs, develops, manufactures, and sells electric vehicles, solar energy generation, and energy storage products.",
        "NVDA": "NVIDIA Corporation provides graphics, computing, and networking solutions worldwide, specializing in GPU technology.",
        "JPM": "JPMorgan Chase & Co. operates as a financial services company providing investment banking, financial services, and asset management.",
        "V": "Visa Inc. operates as a payments technology company worldwide, facilitating digital payments between consumers and merchants.",
        "JNJ": "Johnson & Johnson researches, develops, manufactures, and sells various products in healthcare worldwide.",
        "WMT": "Walmart Inc. engages in the operation of retail, wholesale, and other units worldwide.",
        "PG": "The Procter & Gamble Company provides branded consumer packaged goods worldwide.",
        "MA": "Mastercard Incorporated provides transaction processing and payment services worldwide.",
        "UNH": "UnitedHealth Group Incorporated operates as a diversified healthcare company in the United States.",
        "HD": "The Home Depot Inc. operates as a home improvement retailer providing building materials and home improvement products.",
        "DIS": "The Walt Disney Company operates as an entertainment company worldwide, producing content and operating theme parks.",
        "BAC": "Bank of America Corporation provides banking and financial products and services for individual consumers and businesses.",
        "NFLX": "Netflix Inc. provides entertainment services worldwide, offering streaming content including TV series and films.",
        "ADBE": "Adobe Inc. provides digital media and marketing solutions worldwide, including creative software and document solutions.",
        "CRM": "Salesforce Inc. provides customer relationship management technology and applications worldwide.",
        "CSCO": "Cisco Systems Inc. designs, manufactures, and sells networking and communications technology and services.",
        "PEP": "PepsiCo Inc. manufactures, markets, and sells various beverages, foods, and snacks worldwide.",
        "KO": "The Coca-Cola Company manufactures and sells various beverages worldwide, including soft drinks and water products.",
        "INTC": "Intel Corporation designs, develops, manufactures, and sells computing and communications products worldwide.",
        "NKE": "Nike Inc. designs, develops, markets, and sells athletic footwear, apparel, equipment, and accessories worldwide."
    ]

    init(api: StockAPI) {
        self.api = api
    }

    func streamer() -> StockStreamer {
        let task = api.stocks()
        return StockStreamer(task: task)
    }

    func description(for ticker: String) -> String? {
        descriptions[ticker]
    }
    
    func stocks() -> [Stock] {
        [
            Stock(ticker: "AAPL", name: "Apple Inc.", price: 189.95, priceChange: .unchanged, description: descriptions["AAPL"]),
            Stock(ticker: "MSFT", name: "Microsoft Corporation", price: 374.85, priceChange: .unchanged, description: descriptions["MSFT"]),
            Stock(ticker: "GOOGL", name: "Alphabet Inc.", price: 140.35, priceChange: .unchanged, description: descriptions["GOOGL"]),
            Stock(ticker: "AMZN", name: "Amazon.com Inc.", price: 151.75, priceChange: .unchanged, description: descriptions["AMZN"]),
            Stock(ticker: "META", name: "Meta Platforms Inc.", price: 328.45, priceChange: .unchanged, description: descriptions["META"]),
            Stock(ticker: "TSLA", name: "Tesla Inc.", price: 242.80, priceChange: .unchanged, description: descriptions["TSLA"]),
            Stock(ticker: "NVDA", name: "NVIDIA Corporation", price: 495.22, priceChange: .unchanged, description: descriptions["NVDA"]),
            Stock(ticker: "JPM", name: "JPMorgan Chase & Co.", price: 158.30, priceChange: .unchanged, description: descriptions["JPM"]),
            Stock(ticker: "V", name: "Visa Inc.", price: 267.90, priceChange: .unchanged, description: descriptions["V"]),
            Stock(ticker: "JNJ", name: "Johnson & Johnson", price: 159.45, priceChange: .unchanged, description: descriptions["JNJ"]),
            Stock(ticker: "WMT", name: "Walmart Inc.", price: 163.72, priceChange: .unchanged, description: descriptions["WMT"]),
            Stock(ticker: "PG", name: "Procter & Gamble Co.", price: 163.50, priceChange: .unchanged, description: descriptions["PG"]),
            Stock(ticker: "MA", name: "Mastercard Inc.", price: 425.18, priceChange: .unchanged, description: descriptions["MA"]),
            Stock(ticker: "UNH", name: "UnitedHealth Group Inc.", price: 520.65, priceChange: .unchanged, description: descriptions["UNH"]),
            Stock(ticker: "HD", name: "The Home Depot Inc.", price: 385.40, priceChange: .unchanged, description: descriptions["HD"]),
            Stock(ticker: "DIS", name: "The Walt Disney Company", price: 95.30, priceChange: .unchanged, description: descriptions["DIS"]),
            Stock(ticker: "BAC", name: "Bank of America Corp.", price: 38.75, priceChange: .unchanged, description: descriptions["BAC"]),
            Stock(ticker: "NFLX", name: "Netflix Inc.", price: 485.60, priceChange: .unchanged, description: descriptions["NFLX"]),
            Stock(ticker: "ADBE", name: "Adobe Inc.", price: 498.20, priceChange: .unchanged, description: descriptions["ADBE"]),
            Stock(ticker: "CRM", name: "Salesforce Inc.", price: 265.85, priceChange: .unchanged, description: descriptions["CRM"]),
            Stock(ticker: "CSCO", name: "Cisco Systems Inc.", price: 52.45, priceChange: .unchanged, description: descriptions["CSCO"]),
            Stock(ticker: "PEP", name: "PepsiCo Inc.", price: 172.30, priceChange: .unchanged, description: descriptions["PEP"]),
            Stock(ticker: "KO", name: "The Coca-Cola Company", price: 63.25, priceChange: .unchanged, description: descriptions["KO"]),
            Stock(ticker: "INTC", name: "Intel Corporation", price: 24.15, priceChange: .unchanged, description: descriptions["INTC"]),
            Stock(ticker: "NKE", name: "Nike Inc.", price: 78.90, priceChange: .unchanged, description: descriptions["NKE"])
        ]
    }
}

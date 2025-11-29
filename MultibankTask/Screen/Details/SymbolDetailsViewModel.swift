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
    
    @Published private(set) var ticker: String
    
    init(ticker: String) {
        self.ticker = ticker
    }
}

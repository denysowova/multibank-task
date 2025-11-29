//
//  SymbolDetailsScreen.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct SymbolDetailsScreen: View {
    
    @StateObject private var viewModel: SymbolDetailsViewModel
    
    init(ticker: String) {
        _viewModel = StateObject(wrappedValue: SymbolDetailsViewModel(ticker: ticker))
    }
    
    var body: some View {
        Text("Ticker: \(viewModel.ticker)")
    }
}

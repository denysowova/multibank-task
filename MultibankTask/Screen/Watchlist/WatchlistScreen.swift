//
//  WatchlistScreen.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct WatchlistScreen: View {
    
    @StateObject private var viewModel = WatchlistViewModel(service: StockServiceImpl(repository: StockRepositoryImpl(api: StockAPIImpl())))
    
    var body: some View {
        List(viewModel.items) { item in
            VStack {
                Text(item.ticker)
                Text(item.price)
            }
            .padding(.vertical, 8)
        }
    }
}

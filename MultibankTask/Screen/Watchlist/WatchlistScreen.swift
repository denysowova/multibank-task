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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.ticker)
                        .font(.headline)
                    Text(item.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(item.price)
                        .font(.headline)

                    HStack(spacing: 4) {
                        switch item.priceChange {
                        case .increased:
                            Image(systemName: "arrow.up")
                                .foregroundColor(.green)
                            Text("Up")
                                .font(.caption)
                                .foregroundColor(.green)
                        case .decreased:
                            Image(systemName: "arrow.down")
                                .foregroundColor(.red)
                            Text("Down")
                                .font(.caption)
                                .foregroundColor(.red)
                        case .unchanged:
                            Image(systemName: "minus")
                                .foregroundColor(.gray)
                            Text("Unchanged")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

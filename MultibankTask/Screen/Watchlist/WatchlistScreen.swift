//
//  WatchlistScreen.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct WatchlistScreen: View {
    
    @StateObject private var viewModel = ViewModelFactory.feedViewModel()
    @EnvironmentObject private var router: Router
    
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
            .onTapGesture {
                router.push(.symbolDetails(ticker: item.ticker))
            }
            .padding(.vertical, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("Watchlist"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(viewModel.isConnected ? "🟢 Connected" : "🔴 Disconnected")
                    .fixedSize()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.toggleStreaming()
                    },
                    label: {
                        Image(systemName: viewModel.isUpdating ? "stop.fill" : "play.fill")
                    }
                )
            }
        }
//        .task {
//            viewModel.startStreaming()
//        }
    }
}

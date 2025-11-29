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
            WatchlistRow(item: item)
                .onTapGesture {
                    router.push(.symbolDetails(ticker: item.ticker))
                }
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

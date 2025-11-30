//
//  FeedScreen.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct FeedScreen: View {
    
    @StateObject private var viewModel = ViewModelFactory.feed()
    @EnvironmentObject private var router: Router
    
    var body: some View {
        List(viewModel.items) { item in
            FeedRow(item: item)
                .contentShape(Rectangle())
                .onTapGesture {
                    router.push(.symbolDetails(ticker: item.ticker))
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("Feed"))
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
                .id(UUID())
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil), presenting: viewModel.error) { _ in
            Button("OK") {
                viewModel.error = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .task {
            viewModel.performTasks()
        }
    }
}

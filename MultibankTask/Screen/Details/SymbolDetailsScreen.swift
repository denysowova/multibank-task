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
        _viewModel = StateObject(wrappedValue: ViewModelFactory.symbolDetailsViewModel(withTicker: ticker))
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.companyName)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.ticker)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Price")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(viewModel.price)
                    .font(.system(size: 48, weight: .bold, design: .rounded))

                PriceChangeIndicator(
                    priceChange: viewModel.priceChange,
                    font: .system(size: 48)
                )
            }
        }
    }
    
    private var description: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            Text(viewModel.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            priceSection

            Divider()
            
            description

            Spacer()
        }
        .padding(24)
        .navigationTitle(viewModel.ticker)
        .navigationBarTitleDisplayMode(.inline)
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

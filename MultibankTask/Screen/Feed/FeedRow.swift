//
//  FeedRow.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct FeedRow: View {
    
    let item: FeedItem

    @State private var priceColor: Color = .primary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.ticker)
                    .font(.headline)
                Text(item.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(item.price)
                    .font(.headline)
                    .foregroundColor(priceColor)
                    .animation(.easeInOut(duration: 0.3), value: priceColor)

                PriceChangeIndicator(priceChange: item.priceChange, font: .caption)
            }
        }
        .padding(.vertical, 8)
        .onChange(of: item.price) { oldValue, newValue in
            guard oldValue != newValue else {
                return
            }

            switch item.priceChange {
            case .increased:
                priceColor = .green
            case .decreased:
                priceColor = .red
            case .unchanged:
                return
            }

            Task {
                try? await Task.sleep(for: .seconds(1))
                
                await MainActor.run {
                    priceColor = .primary
                }
            }
        }
    }
}


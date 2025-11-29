//
//  WatchlistRow.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct WatchlistRow: View {
    
    let item: WatchlistItem

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

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.price)
                    .font(.headline)
                    .foregroundColor(priceColor)
                    .animation(.easeInOut(duration: 0.3), value: priceColor)

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


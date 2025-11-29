//
//  PriceChangeIndicator.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI

struct PriceChangeIndicator: View {
    
    let priceChange: PriceChange
    let font: Font

    var body: some View {
        switch priceChange {
        case .increased:
            Image(systemName: "arrow.up")
                .font(font)
                .foregroundColor(.green)
        case .decreased:
            Image(systemName: "arrow.down")
                .font(font)
                .foregroundColor(.red)
        case .unchanged:
            Image(systemName: "minus")
                .font(font)
                .foregroundColor(.gray)
        }
    }
}

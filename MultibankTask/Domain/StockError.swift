//
//  StockError.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import Foundation

enum StockError: LocalizedError {
    case networking(Error)
    case notFound
    
    var errorDescription: String? {
        switch self {
            case .networking(let error):
            return "Networking error: \(error.localizedDescription)"
        case .notFound:
            return "Stock not found"
        }
    }
}

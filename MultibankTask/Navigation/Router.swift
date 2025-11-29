//
//  Router.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 29.11.25.
//

import SwiftUI
import Combine

@MainActor
enum Route: Hashable {
    case feed
    case symbolDetails(ticker: String)
}

extension Route {
    
    @ViewBuilder
    func destination() -> some View {
        switch self {
        case .feed:
            WatchlistScreen()
        case .symbolDetails(let ticker):
            SymbolDetailsScreen(ticker: ticker)
        }
    }
}

@MainActor
final class Router: ObservableObject {
    
    @Published var path = NavigationPath()
    
    let root: Route = .feed
    
    func push(_ route: Route) {
        path.append(route)
    }
}

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
            FeedScreen()
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
    
    func handleDeeplink(_ url: URL) {
        guard let host = url.host() else {
            return
        }
        
        let route: Route
        
        switch host {
        case "symbol":
            let ticker = url.lastPathComponent
            route = .symbolDetails(ticker: ticker)
        default:
            return
        }
        
        push(route)
    }
}

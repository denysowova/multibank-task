//
//  MultibankTaskApp.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 28.11.25.
//

import SwiftUI

@main
struct MultibankTaskApp: App {
    
    @StateObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                router.root.destination()
                    .navigationDestination(for: Route.self) { route in
                        route.destination()
                    }
            }
            .environmentObject(router)
            .onOpenURL { url in
                router.handleDeeplink(url)
            }
        }
    }
}

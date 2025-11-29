//
//  ContentView.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 28.11.25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel(service: StockServiceImpl(repository: StockRepositoryImpl(api: StockAPIImpl())))
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Test") {
//                viewModel.test()
            }
        }
        .padding()
        .task {
//            viewModel.setUp()
        }
    }
}

#Preview {
    ContentView()
}

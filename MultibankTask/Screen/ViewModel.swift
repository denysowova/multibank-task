//
//  ViewModel.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 28.11.25.
//

import Foundation
import Combine

//struct WebSocketMessage: Codable, Sendable {
//    let text: String
//}

@MainActor
final class ViewModel: ObservableObject {
    
    private let service: StockService
    
    init(service: StockService) {
        self.service = service
    }
    
//    private let webSocket = WebSocketTask<WebSocketMessage, WebSocketMessage>(
//        url: URL(string: "wss://ws.postman-echo.com/raw")!
//    )
    
//    private var cancellable: AnyCancellable?
    
//    func setUp() {
//        cancellable = webSocket.messages
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { completion in
//                    print("Completed: \(completion)")
//                },
//                receiveValue: { message in
//                    print("Received: \(message)")
//                }
//            )
//        
//        do {
//            try webSocket.start()
//        } catch {
//            print("error starting: \(error.localizedDescription)")
//        }
//    }
    
//    func test() {
//        Task {
//            let message = WebSocketMessage(text: "Hello, it's a test")
//            do {
//                try await webSocket.sendMessage(message)
//            } catch {
//                print("Error sending message: \(error.localizedDescription)")
//            }
//        }
//    }
}

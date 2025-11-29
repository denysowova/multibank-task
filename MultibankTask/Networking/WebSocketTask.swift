//
//  WebSocketTask.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 28.11.25.
//

import Foundation
import Combine

final class WebSocketTask<InMessage: Decodable & Sendable, OutMessage: Encodable & Sendable>:
    NSObject, URLSessionTaskDelegate, @unchecked Sendable {

    private let session = URLSession(configuration: .default)
    private let socket: URLSessionWebSocketTask
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var socketTask: Task<Void, Never>?
    private var hasTerminated = false
    
    private let _messages = PassthroughSubject<InMessage, WebSocketTaskError>()
    
    var messages: AnyPublisher<InMessage, WebSocketTaskError> {
        _messages.eraseToAnyPublisher()
    }

    init(url: URL) {
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("z0WnkWwdJ4TAwakOKLWLXg==", forHTTPHeaderField: "Sec-WebSocket-Key")
//        request.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
//        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
//        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        
        socket = session.webSocketTask(with: request)

        super.init()

        socket.delegate = self
    }

    deinit {
        terminateStream()
    }

    private func receiveMessage() async {
        do {
            let message = try await socket.receive()

            switch message {
            case .string(let text):
                guard let data = text.data(using: .utf8) else {
                    terminateStream(withError: .invalidResponse)
                    return
                }

                do {
                    let response = try decoder.decode(InMessage.self, from: data)
                    _messages.send(response)
                    await receiveMessage()
                } catch {
                    terminateStream(withError: .decoding(raw: error, data: data))
                }

            case .data:
                terminateStream(withError: .invalidResponse)

            @unknown default:
                terminateStream(withError: .invalidResponse)
            }
        } catch {
            terminateStream(withError: .streamError(raw: error))
        }
    }

    private func terminateStream(withError error: WebSocketTaskError? = nil) {
        if let error {
            _messages.send(completion: .failure(error))
        } else {
            _messages.send(completion: .finished)
        }

        socketTask?.cancel()
        socketTask = nil

        switch error {
        case .terminated, .streamError, .encoding:
            socket.cancel(with: .abnormalClosure, reason: nil)
        case .invalidResponse, .decoding:
            socket.cancel(with: .invalidFramePayloadData, reason: nil)
        case nil:
            socket.cancel(with: .normalClosure, reason: nil)
        }

        hasTerminated = true
    }

    func start() throws (WebSocketTaskError) {
        guard !hasTerminated else {
            throw .terminated
        }

        socket.resume()

        socketTask = Task {
            await receiveMessage()
        }
    }

    func terminate() {
        terminateStream(withError: nil)
    }

    func sendMessage(_ message: OutMessage) async throws (WebSocketTaskError) {
        let body: String

        do {
            let encodedBody = try encoder.encode(message)
            body = String(data: encodedBody, encoding: .utf8)!
        } catch {
            throw .encoding(raw: error)
        }

        do {
            try await socket.send(.string(body))
        } catch {
            throw .streamError(raw: error)
        }
    }

    // MARK: - URLSessionTaskDelegate

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        terminateStream(withError: .streamError(raw: error))
    }
}

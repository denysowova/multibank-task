//
//  WebSocketTaskError.swift
//  MultibankTask
//
//  Created by Volodymyr Denysov on 28.11.25.
//

import Foundation

enum WebSocketTaskError: LocalizedError {
    case terminated
    case streamError(raw: Error?)
    case encoding(raw: Error)
    case decoding(raw: Error, data: Data)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .terminated:
            "Web socket task has already completed or has been terminated"
        case .streamError(let raw):
            if let raw {
                "Streaming error occurred streaming via web socket: \(raw.localizedDescription)"
            } else {
                "Streaming error occurred streaming via web socket"
            }
        case .encoding(let raw):
            "Error encoding a web socket message: \(raw.localizedDescription)"
        case .decoding(let raw, let data):
            """
            Error decoding a web socket message: \(raw.localizedDescription)\n.
            Raw data: \(String(data: data, encoding: .utf8) ?? data.debugDescription)
            """
        case .invalidResponse:
            "Invalid response received by a web socket"
        }
    }
}

//
//  OpenTDBModels.swift
//  Trivia
//
//  Created by Armaan Tulsyani on 10/22/25.
//

import Foundation

struct OpenTDBResponse: Decodable {
    let response_code: Int
    let results: [OpenTDBQuestion]
}

struct OpenTDBQuestion: Decodable {
    let category: String
    let type: String        // "multiple" or "boolean"
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

enum TriviaAPIError: LocalizedError {
    case nonZeroResponseCode(Int)
    case badURL
    case emptyResults
    case network(Error)
    case decoding(Error)
    
    var errorDescription: String? {
        switch self {
        case .nonZeroResponseCode(let c): return "API returned non-success response_code: \(c)"
        case .badURL: return "Could not build request URL."
        case .emptyResults: return "No questions were returned."
        case .network(let e): return "Network error: \(e.localizedDescription)"
        case .decoding(let e): return "Decoding error: \(e.localizedDescription)"
        }
    }
}

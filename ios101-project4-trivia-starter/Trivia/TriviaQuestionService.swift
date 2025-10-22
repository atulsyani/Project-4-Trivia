//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Armaan Tulsyani on 10/22/25.
//

import Foundation

final class TriviaQuestionService {
    static let shared = TriviaQuestionService()
    private init() {}

    /// Fetches questions from OpenTDB.
    /// - Parameters:
    ///   - amount: number of questions (default 5)
    ///   - categoryID: optional OpenTDB category id (e.g. 9=General Knowledge)
    ///   - difficulty: optional "easy" | "medium" | "hard"
    ///   - type: optional "multiple" | "boolean" (omit to allow both)
    func fetchQuestions(
        amount: Int = 5,
        categoryID: Int? = nil,
        difficulty: String? = nil,
        type: String? = nil,
        completion: @escaping (Result<[TriviaQuestion], TriviaAPIError>) -> Void
    ) {
        var comps = URLComponents(string: "https://opentdb.com/api.php")
        var query: [URLQueryItem] = [URLQueryItem(name: "amount", value: String(amount))]
        if let categoryID { query.append(.init(name: "category", value: String(categoryID))) }
        if let difficulty { query.append(.init(name: "difficulty", value: difficulty)) }
        if let type { query.append(.init(name: "type", value: type)) }
        comps?.queryItems = query

        guard let url = comps?.url else {
            completion(.failure(.badURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, err in
            if let err { return completion(.failure(.network(err))) }
            guard let data else { return completion(.failure(.emptyResults)) }

            do {
                let decoded = try JSONDecoder().decode(OpenTDBResponse.self, from: data)
                guard decoded.response_code == 0 else {
                    return completion(.failure(.nonZeroResponseCode(decoded.response_code)))
                }
                let mapped: [TriviaQuestion] = decoded.results.map { q in
                    TriviaQuestion(
                        category: q.category.htmlDecoded,
                        question: q.question.htmlDecoded,
                        correctAnswer: q.correct_answer.htmlDecoded,
                        incorrectAnswers: q.incorrect_answers.map { $0.htmlDecoded }
                    )
                }
                if mapped.isEmpty {
                    completion(.failure(.emptyResults))
                } else {
                    completion(.success(mapped))
                }
            } catch {
                completion(.failure(.decoding(error)))
            }
        }.resume()
    }
}


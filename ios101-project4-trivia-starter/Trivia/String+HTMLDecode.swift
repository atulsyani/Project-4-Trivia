//
//  String+HTMLDecode.swift
//  Trivia
//
//  Created by Armaan Tulsyani on 10/22/25.
//

import UIKit

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attr = try? NSAttributedString(data: data, options: opts, documentAttributes: nil) {
            return attr.string
        }
        return self
    }
}


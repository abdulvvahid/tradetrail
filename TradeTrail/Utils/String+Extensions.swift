//
//  String+Extensions.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import Foundation

extension String {
    var cleanedForDouble: String {
        self
            .replacingOccurrences(of: "\"", with: "") // <-- çift tırnak temizleniyor
            .filter { $0.isNumber || $0 == "." || $0 == "-" }
    }
}

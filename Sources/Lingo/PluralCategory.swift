//
//  PluralCategory.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 13.05.24.
//

import Foundation

/// Represents plural category from Unicode Common Locale Data
/// http://cldr.unicode.org/index/cldr-spec/plural-rules
public enum PluralCategory: String, Sendable {
    case zero
    case one    // singular
    case two    // dual
    case few    // paucal
    case many   // also used for fractions if they have a separate class
    case other  // required—general plural form—also used if the language only has a single form
}

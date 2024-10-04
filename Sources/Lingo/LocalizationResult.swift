//
//  LocalizationResult.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 13.05.24.
//

import Foundation

public enum LocalizationResult {
    case success(localization: String)
    case missingLocale
    case missingKey
}

//
//  PluralizationRule.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 13.05.24.import Foundation
//

public protocol AbstractPluralizationRule {
    /// Returns matching `PluralCategory` for given numeric value.
    /// http://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html
    func pluralCategory(forNumericValue: UInt) -> PluralCategory
    /// Returns a list of all available PluralCategories
    var availablePluralCategories: [PluralCategory] { get }
}

public protocol LocaleIdentifiable {
    var locale: LocaleIdentifier { get }
}

public protocol PluralizationRule: AbstractPluralizationRule, LocaleIdentifiable, Sendable { }

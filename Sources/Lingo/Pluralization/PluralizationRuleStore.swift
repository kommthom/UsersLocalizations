//
//  PluralizationRuleStore.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 13.05.24.
//

import UserDTOs

public struct PluralizationRuleStore: Sendable {
    public static func pluralizationRule(forLocale locale: LocaleIdentifier) -> PluralizationRule? {
        if let exactPluralizationRule = self.allPluralizationRulesMap[locale] { return exactPluralizationRule }
        /// If exact `PluralizationRule` is not found (exact meaning that both language
        /// and country match), fall back to matching only language code as the pluralization
        /// rules almost never differ between countries for the same language.
		let arrayLocale = locale.rawValue.components(separatedBy: "-")
		if arrayLocale.count == 2 {
			return self.pluralizationRule(
				forLocale: LocaleIdentifier(
					arrayLocale.first!
				)
			)
		}
        return nil
    }
    
    public static func availablePluralCategories(forLocale locale: LocaleIdentifier) -> [PluralCategory] {
        return self.pluralizationRule(forLocale: locale)?.availablePluralCategories ?? []
    }
}

private extension PluralizationRuleStore {
    /// Returns a map of all LocaleIdentifiers to it's PluralizationRules for a faster access
	static let allPluralizationRulesMap: [LocaleIdentifier: PluralizationRule] = {
        var rulesMap = [LocaleIdentifier: PluralizationRule]()
        for rule in PluralizationRuleStore.all {
            rulesMap[rule.locale] = rule
        }
        return rulesMap
    }()
}

//
//  KeyWords.swift
//
//
//  Created by Thomas Benninghaus on 13.05.24.
//

import Tagged
import UserDTOs

public actor KeyWords: Sendable, LocalizationsProtocol  {
	public typealias Key = KeyWord.Key
	public typealias Value = KeyWord.Value
	
	private var data = [LocaleIdentifier: [Key: Value]]()
	private var translators: [LocaleIdentifier: KeyWordTranslator]
	
	public init(data: [LocaleIdentifier: [Key: Value]] = .init()) {
		self.data = data
		self.translators = .init()
	}

	public func getTranslator(forLocale locale: LocaleIdentifier) async throws -> (any TranslatorProtocol)? {
		if let translator = translators[locale] { return translator }
		guard let localeBucket = self.data[locale] else { throw LingoError.missingLocale(locale: locale.rawValue) }
		let translator = KeyWordTranslator(languageCode: locale, localizations: localeBucket)
		translators[locale] = translator
		return translator
	}
}

extension KeyWords {
	public func addLocalizations(from dtos: [LocalizationDTO]) async -> Void {
		self.data = dtos
			.sorted { $0 < $1 }
			.reduce(into: [LocaleIdentifier: [Key: Value]]()) { dict, localization  in
				let value = Value(CompositeString(stringLiteral: localization.value!))
				let localeIdentifier: LocaleIdentifier = LocaleIdentifier(stringLiteral: localization.identifier.rawValue)
				let localizationKey: Key = Key(stringLiteral: localization.key.rawValue)
				if let _ = dict[localeIdentifier] { // key is already there
					dict[localeIdentifier]![localizationKey] = value
				} else {
					var newDict = [Key: Value]()
					newDict[localizationKey] = value
					dict[localeIdentifier] = newDict
				}
			}
	}
	
	public func addLocalizations(_ localizations: [Key: Value], `for` locale: LocaleIdentifier) async -> Void {
		// Find existing bucket for a given locale or create a new one
		if var existingLocaleBucket = self.data[locale] {
			for (localizationKey, localization) in localizations {
				existingLocaleBucket[localizationKey] = localization
				self.data[locale] = existingLocaleBucket
			}
		} else {
			self.data[locale] = localizations
		}
	}
	
	public func addLocalization(_ key: Key, value: Value, `for` locale: LocaleIdentifier) async -> Void {
		// Find existing bucket for a given locale or create a new one
		if var existingLocaleBucket = self.data[locale] {
			existingLocaleBucket[key] = value
			if translators[locale] != nil { translators[locale] = nil }
		} else {
			self.data[locale] = [key: value]
		}
	}
}

//extension KeyWords {
//	private static func filter(localeBucket: [Key: Value], matching predicate: Predicate<Key>) -> [Key: Value] {
//		localeBucket.filter(predicate.matches)
//	}
//	
//	private static func firstKey(localeBucket: [Key: Value], matching predicate: Predicate<CompositeStringDictionaryElement>) -> Key? {
//		localeBucket.first(where: predicate.matches)?.key
//	}
//	
//    /// Returns localized string of a given key in the given locale.
//    /// If string contains interpolations, they are replaced from the dictionary.
//    public func localize(_ key: Key, locale: LocaleIdentifier, interpolations: [String: Any]? = nil) -> LocalizationResult {
//        guard let localeBucket = self.data[locale] else { return .missingLocale }
//        guard let localization = localeBucket[key] else { return .missingKey }
//		return .success(localization: localization.rawValue.rawValue)
//    }
//    
//	public func findTranslatedKeyWord(locale: LocaleIdentifier = LanguageDTO.Identifier.notSet.description, rawValue: String) -> Key? {
//        let lowerCasedValue = rawValue.lowercased()
//        let filtered = KeyWords.filter(localeBucket: self.data[locale]!, matching: .hasPrefix(comparedTo: lowerCasedValue))
//        guard !filtered.isEmpty else { return nil }
//        if locale == LanguageIdentifier.notSet.description && filtered.count == 1 { return filtered.first!.key }
//        return KeyWords.firstKey(localeBucket: filtered, matching: .hasSuffix(comparedTo: lowerCasedValue))
//    }
//}

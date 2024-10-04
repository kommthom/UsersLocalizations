//
//  LocalizationsModel.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 13.05.24.
//

import Tagged
import UserDTOs

public actor Localizations: @unchecked Sendable, LocalizationsProtocol {
	public typealias Key = String
    public typealias Value = Localization
    
	private var data = [LocaleIdentifier: [Key: Value]]()
	private var translators: [LocaleIdentifier: Translator]
	
	public init(data: [LocaleIdentifier : [Key : Localization]] = [LocaleIdentifier: [Key: Value]]()) {
		self.data = data
		self.translators = [:]
	}

	/// singleton to get translation and back translation functionality
	public func getTranslator(forLocale locale: LocaleIdentifier) async throws -> (any TranslatorProtocol)? {
		if let translator = translators[locale] { return translator }
		guard let localeBucket = self.data[locale] else { throw LingoError.missingLocale(locale: locale.rawValue) }
		let translator = Translator(languageCode: locale, localizations: localeBucket)
		translators[locale] = translator
		return translator
	}
}

extension Localizations {
	public func addLocalizations(from dtos: [UserDTOs.LocalizationDTO]) async throws {
		self.data = try dtos
			.sorted { $0 < $1 }
			.reduce(into: [LocaleIdentifier: [Key: Value]]()) { dict, localization  in
				let value = try localization.localization
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
	
	public func addLocalizations(_ localizations: [Key: Value], `for` locale: LocaleIdentifier) async -> Void{
        // Find existing bucket for a given locale or create a new one
        if var existingLocaleBucket = self.data[locale] {
            for (key, localization) in localizations {
                existingLocaleBucket[key] = localization
                self.data[locale] = existingLocaleBucket
            }
			if translators[locale] != nil { translators[locale] = nil }
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

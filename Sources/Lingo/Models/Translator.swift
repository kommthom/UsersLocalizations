//
//  Translator.swift
//  common-localizations
//
//  Created by Thomas Benninghaus on 27.08.24.
//

public struct Translator: TranslatorProtocol {
	public typealias Key = String
	public typealias Value = String
	public typealias ParseResult = Key
	
	private let localizations: [Key: Localization]
	private var inversed: [Localization: Key]
	public var languageCode: LocaleIdentifier
	
	public init(languageCode: LocaleIdentifier, localizations: [Key: Localization]) {
		self.languageCode = languageCode
		self.localizations = localizations
		self.inversed = [Localization: Key]()
		for (key, localization) in localizations {
			//let value: Value = localizations[key]! //.value(forLocale: languageCode, interpolations: localizations)
			self.inversed[localization] = key
		}
	}
	
	public var translate: @Sendable (_ key: Key, _ interpolations: [Key: Value]?) throws -> Value {
		return { key, interpolations in
			guard let localization = self.localizations[key] else { throw LingoError.missingKey(key: key) }
			return localization.value(forLocale: self.languageCode, interpolations: interpolations)
			//return .success(localization: localizedString)
		}
	}
	
	public var reTranslate: @Sendable (_ value: Value) throws -> ParseResult {
		return { value in
			//guard let localization = Localization.universal(value: value) else { throw LingoError.missingValue(value: value) } // ToDo: implement pluralized!
			let localization = Localization.universal(value: value)
			if let result = self.inversed[localization] { return result }
			return ""
		}
	}
}

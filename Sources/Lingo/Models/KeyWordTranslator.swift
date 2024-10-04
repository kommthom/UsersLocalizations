//
//  KeyWordTranslator.swift
//  common-localizations
//
//  Created by Thomas Benninghaus on 27.08.24.
//

import Tagged

public struct KeyWordTranslator: TranslatorProtocol {
	public typealias Key = String
	public typealias Value = String
	public typealias ParseResult = (next: Value, match: Key)
	
	private let localizations: [Key: CompositeString]
	private let inversed: CompositeStringStringTuples
	public var languageCode: LocaleIdentifier
	
	public init(languageCode: LocaleIdentifier, localizations: [KeyWord.Key: KeyWord.Value]) {
		self.languageCode = languageCode
		var initLocalizations = [Key: CompositeString]()
		var inversed = [CompositeString: Key]()
		for (key, value) in localizations {
			let newValue: CompositeString = value.rawValue
			initLocalizations[key.rawValue] = newValue
			inversed[newValue] = key.rawValue
		}
		self.localizations = initLocalizations
		self.inversed = CompositeStringStringTuples(
			tuples: inversed
				.map { (key, value) in
					(key, value)
				}
		)
	}
	
	public var translate: @Sendable (_ key: Key, _ interpolations: [Key: Value]?) throws -> Value {
		return { key, interpolations in
			self.localizations[key]!.first
		}
	}
	
	public var reTranslate: @Sendable (_ value: Value) throws -> ParseResult {
		return { value in
			guard let newKeyValue: CompositeStringStringTuples.Tuple = inversed.first(matching: .hasPrefix(comparedTo: value)) else { return (next: value, match: "")}
			return newKeyValue.0.parse(comparedTo: value)
		}
	}
}

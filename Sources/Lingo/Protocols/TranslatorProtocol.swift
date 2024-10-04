//
//  TranslatorProtocol.swift
//  common-localizations
//
//  Created by Thomas Benninghaus on 27.08.24.
//

public protocol TranslatorProtocol: Sendable {
	associatedtype Key: Sendable & Equatable & Hashable
	associatedtype Value: Sendable
	associatedtype ParseResult: Sendable //(next: Value, match: Key) or Key
	
	var languageCode: LocaleIdentifier { get set }
	/// Returns localized string of a given key in the given locale.
	/// If string contains interpolations, they are replaced from the dictionary.
	var translate: @Sendable (_ key: Key, _ interpolations: [Key: Value]?) throws -> Value { get }
	var reTranslate: @Sendable (_ value: Value) throws -> ParseResult { get }
}
//
//public protocol KeyWordTranslatorProtocol: Sendable {
//	associatedtype Key: Sendable
//	associatedtype Value: Sendable
//	
//	var languageCode: LocaleIdentifier { get set }
//	var translate: @Sendable (Key) -> Value { get }
//	var reTranslate: @Sendable (Value) -> (next: Value, match: Key) { get }
//	/// Returns localized string of a given key in the given locale.
//	/// If string contains interpolations, they are replaced from the dictionary.
//	func localize(_ key: Key, interpolations: [String: Any]?) -> LocalizationResult
//}

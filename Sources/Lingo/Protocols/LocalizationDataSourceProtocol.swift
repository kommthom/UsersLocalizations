//
//  LocalizationDataSourceProtocol.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 13.05.24.
//

import Tagged
import UserDTOs

/// Types conforming to this protocol can be used to initialize Lingo.
///
/// Use it in case your localizations are not stored in JSON files, but rather in a database or other storage technology.
public protocol LocalizationDataSourceProtocol: Sendable {
    /// Return a list of available locales.
    /// Lingo will query for localizations for each of these locales in localizations(for:) method.
	func availableLocales() async throws -> [LocaleIdentifier]
    
    /// Return localizations for a given locale.
	func localizations(forLocale locale: LocaleIdentifier) async throws -> [Localizations.Key: Localization]
}

/// Types conforming to this protocol can be used to initialize Lingo. Async Version
///
/// Use it in case your localizations are not stored in JSON files, but rather in a database or other storage technology.
public protocol KeyWordDataSourceProtocol: Sendable {
	/// Return a list of available locales.
	/// Lingo will query for localizations for each of these locales in localizations(for:) method.
	func availableLocales() async throws -> [LocaleIdentifier]
	/// Return localizations as KeyWords for a given locale.
	func localizations(forLocale locale: LocaleIdentifier) async throws -> [KeyWords.Key: KeyWords.Value]?
}

public protocol ExtensibleLocalizationDataSourceProtocol: LocalizationDataSourceProtocol {
	//// Append value for a given localization and key
	func appendLocalization(forLocale locale: LocaleIdentifier, localizationKey: Localizations.Key, value: Localizations.Value) async throws -> Void
}

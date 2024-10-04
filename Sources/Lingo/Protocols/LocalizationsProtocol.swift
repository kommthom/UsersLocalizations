//
//  LocalizationsProtocol.swift
//  common-localizations
//
//  Created by Thomas Benninghaus on 27.08.24.
//

import UserDTOs

public protocol LocalizationsProtocol: Sendable {
	associatedtype Key: Sendable & Equatable & Hashable
	associatedtype Value: Sendable & Equatable & Hashable
	
	func addLocalizations(from dtos: [LocalizationDTO]) async throws -> Void
	func addLocalizations(_ localizations: [Key: Value], `for` locale: LocaleIdentifier) async -> Void
	func addLocalization(_ key: Key, value: Value, `for` locale: LocaleIdentifier) async -> Void
	func getTranslator(forLocale locale: LocaleIdentifier) async throws -> (any TranslatorProtocol)?
}

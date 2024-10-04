//
//  Lingo.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 28.08.24.
//

import Tagged
import Foundation
import UserDTOs

public typealias LocaleIdentifier = UserDTOs.LocaleDTO.Identifier //Tagged<Lingo, String>

public final class Lingo: Sendable {
	public let defaultLocale: LocaleIdentifier
	public let dataSource: LocalizationDataSourceProtocol
	private let model: Localizations
	
	/// Convenience initializer for Lingo.
	///
	/// - `rootPath` should contain localization files in JSON format
	/// named based on relevant locale. For example: en.json, de.json etc.
	/// - `defaultLocale` will be used as a fallback when no localizations are available for a requested locale.
	public convenience init(rootPath: String, defaultLocale: LocaleIdentifier) async throws {
		guard let dataSource = FileDataSource(rootPath: rootPath) else { throw LingoError.rootPathNotValid(path: rootPath) }
		try await self.init(dataSource: dataSource, defaultLocale: defaultLocale)
	}
	
	/// Initializes Lingo with a `LocalizationDataSource`.
	/// - `defaultLocale` will be used as a fallback when no localizations are available for a requested locale.
	public init(dataSource: LocalizationDataSourceProtocol, defaultLocale: LocaleIdentifier) async throws {
		self.dataSource = dataSource
		self.defaultLocale = defaultLocale
		self.model = Localizations()
		let validator = LocaleValidator()
		for locale in try await dataSource.availableLocales() {
			// Check if locale is valid. Invalid locales will not cause any problems in the runtime,
			// so this validation should only warn about potential mistype in locale names.
			if validator.validate(locale: locale) {
				print("Valid locale identifier found: \(locale)")
			} else {
				print("WARNING: Invalid locale identifier: \(locale)")
			}

			let localizations = try await dataSource.localizations(forLocale: locale)
			await self.model.addLocalizations(localizations, for: locale)
		}
	}
	
	private func getTranslatorForLocale(locale: LocaleIdentifier) async -> Translator? {
		var localesQueue: [String] = [locale.rawValue]
		let localeComponents = localesQueue.first!.components(separatedBy: "-")
		if localeComponents.count == 2 { localesQueue.append(localeComponents.first!) }
		localesQueue.append(self.defaultLocale.rawValue)
		var previousLocale: LocaleIdentifier? = nil
		var translator: Translator? = nil
		repeat {
			//translator = await getTranslatorForLocaleQueue(queue: &localesQueue, previousLocale: &previousLocale)
			if let localeNN = previousLocale?.rawValue {
				print("Missing localization locale: \(localeNN). Will try code: \(localesQueue.first!) instead.")
			}
			previousLocale = LocaleIdentifier(stringLiteral: localesQueue.removeFirst())
			do {
				translator = try await self.model
					.getTranslator(forLocale: previousLocale!) as? Translator
			} catch LingoError.missingLocale(_) {
			} catch {
				print("Unexpected error: \(error).")
				localesQueue.removeAll()
			}
		} while translator == nil && !localesQueue.isEmpty
		return translator
	}
	
	/// Returns localized string for the given key in the requested locale.
	/// If string contains interpolations, they are replaced from the `interpolations` dictionary.
	public func localize(_ key: Localizations.Key, locale: LocaleIdentifier, interpolations: [String: String]? = nil) async -> String {
		guard let translator = await getTranslatorForLocale(locale: locale) else {
			print("No localizations found for locale: \(locale). Will fallback to raw value of the key.")
			return key
		}
		do {
			return try translator
				.translate(key, interpolations)
		} catch LingoError.missingKey(let key) {
			print("No localizations found for key: \(key), locale: \(locale). Will fallback to raw value of the key.")
			return key
		} catch {
			print("Unexpected error: \(error).")
			return "\(error)"
		}
	}
	
	public func getKey(_ value: Translator.Value, locale: LocaleIdentifier) async -> Translator.ParseResult {
		//reTranslate: @Sendable (_ value: Value) -> ParseResult
		guard let translator = await getTranslatorForLocale(locale: locale) else {
			print("No localizations found for locale: \(locale). Will fallback to raw value of the key.")
			return value
		}
		do {
			return try translator
				.reTranslate(value)
		} catch LingoError.missingValue(let value) {
			print("No localizations found for value: \(value), locale: \(locale). Will fallback to raw value as the key.")
			return value
		} catch {
			print("Unexpected error: \(error).")
			return "\(error)"
		}
	}
	
	/// Returns a list of all available PluralCategories for locale
	public static func availablePluralCategories(forLocale locale: LocaleIdentifier) -> [PluralCategory] {
		return PluralizationRuleStore.availablePluralCategories(forLocale: locale)
	}
	
}

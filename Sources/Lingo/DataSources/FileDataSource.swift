//
//  FileDataSource.swift
//  common-localizations
//
//  Created by Miroslav Kovac (Lingo).
//  Updated by Thomas Benninghaus on 28.08.24.
//

import Foundation
import Tagged
import UserDTOs

/// Class providing file backed data source for Lingo in case localizations are stored in JSON files.
public final class FileDataSource: LocalizationDataSourceProtocol {
    enum Error: Swift.Error {
        case parsingFailure(message: String)
    }
    public let rootPath: String
	public var rootPathUrl: URL { return URL(string: rootPath)! }
    
    /// `rootPath` should contain localization files in JSON format named based on relevant locale. For example: en.json, de.json etc.
    public init?(rootPath: String) {
		self.rootPath = rootPath
    }
    
    // MARK: LocalizationDataSource
	public func availableLocales() async throws -> [LocaleIdentifier] {
		let files = walkDirectory(at: self.rootPathUrl)
			.filter {
				$0.pathExtension == "json"
			}
		return await files
			.reduce([LocaleIdentifier]()) { (identifiers, url) in
				let localeName = url.lastPathComponent.components(separatedBy: ".").first! // It is safe to use force unwrap here as $0 will always contain the "."
				var newIdentifiers = identifiers
				newIdentifiers.append(LocaleIdentifier(stringLiteral: localeName))
				return newIdentifiers
			}
	}
    
	public func localizations(forLocale locale: LocaleIdentifier) async throws -> [Localizations.Key : Localization] {
		let jsonFilePath = URL(fileURLWithPath: self.rootPath
			.appending("/\(locale.rawValue).json"))
		var localizations = [Localizations.Key: Localization]()
        
        // Parse localizations. Note that valid `object` in the for-loop can be either:
        // - a String, in case there are no pluralizations defined (one, few, many, other,..)
        // - a dictionary [String: String], in case pluralizations are defined
        for (localizationKey, object) in try await self.loadLocalizations(atPath: jsonFilePath) {
            if let stringValue = object as? String {
                let localization = Localization.universal(value: stringValue)
                localizations[localizationKey] = localization
            } else if let rawPluralizedValues = object as? [String: String] {
                let pluralizedValues = try self.pluralizedValues(fromRaw: rawPluralizedValues)
                let localization = Localization.pluralized(values: pluralizedValues)
                localizations[localizationKey] = localization
                
            } else {
                throw Error.parsingFailure(message: "Unsupported pluralization format for key: \(localizationKey).")
            }
        }
        return localizations
    }
}

private extension FileDataSource {
    /// Parses a dictionary which has string plural categories as keys ([String: String]) and returns a typed dictionary ([PluralCategory: String])
    /// An example dictionary looks like:
    /// {
    ///   "one": "You have an unread message."
    ///   "many": "You have %{count} unread messages."
    /// }
    func pluralizedValues(fromRaw rawPluralizedValues: [String: String]) throws -> [PluralCategory: String] {
        var result = [PluralCategory: String]()
        for (rawPluralCategory, value) in rawPluralizedValues {
            guard let pluralCategory = PluralCategory(rawValue: rawPluralCategory) else { throw Error.parsingFailure(message: "Unsupported plural category: \(rawPluralCategory)") }
            result[pluralCategory] = value
        }
        return result
    }
    
    /// Loads a localizations file from disk if it exists and parses it.
    func loadLocalizations(atPath path: URL) async throws -> [String: Any] {
        let fileContent = try await Data(asyncContentsOf: path)
        let jsonObject = try JSONSerialization.jsonObject(with: fileContent, options: [])
        guard let localizations = jsonObject as? [String: Any] else {
            throw Error.parsingFailure(message: "Invalid localization file format at path: \(path). Expected string indexed dictionary at the root level.")
        }
        return localizations
    }
}

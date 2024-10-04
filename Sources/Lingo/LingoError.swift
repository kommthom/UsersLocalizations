//
//  LingoError.swift
//  users-localizations
//
//  Created by Thomas Benninghaus on 30.09.24.
//

public enum LingoError: Swift.Error {
	case parsingFailure(message: String)
	case missingLocale(locale: String)
	case missingKey(key: String)
	case missingValue(value: String)
	case rootPathNotValid(path: String)
}

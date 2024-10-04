//
//  String+Split.swift
//  common-localizations
//
//  Created by Thomas Benninghaus on 26.08.24.
//

import Foundation

extension String {
	public func split(separators: [String]) -> [String] {
		return separators.reduce([self]) { result, separator in
			return result.flatMap { $0.split(separator: separator).map { String($0) } }
		}
		.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
	}
	
	public func eliminatePrefix(_ prefix: String) -> String? {
		self.hasPrefix(prefix) ? String(self.suffix(from: self.index(self.startIndex, offsetBy: prefix.count))) : nil
	}
}

/* Usage */
//"hello.there/how?are!you".split(separators: [".", "/", "?", "!"])
/* Result: ["hello", "there", "how", "are", "you"] */

extension String {
	public func deletingPrefix(_ prefix: String) -> String {
		guard self.hasPrefix(prefix) else { return self }
		return String(self.dropFirst(prefix.count))
	}
}

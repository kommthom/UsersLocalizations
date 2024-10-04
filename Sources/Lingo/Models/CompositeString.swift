//
//  CompositeString.swift
//
//
//  Created by Thomas Benninghaus on 27.04.24.
//

import Foundation

public struct CompositeString: RawRepresentable, Hashable, Sendable {
    public typealias RawValue = String
    
    public var rawValue: RawValue
    public var prefix: String
    public var suffixes: [String]
	public var first: String {
		prefix + (suffixes.first ?? "")
	}
	
	public func hasPrefix(comparedTo string: String) -> Bool {
		guard suffixes.count > 0 else { return string.hasPrefix(self.prefix) }
		for suffix in suffixes {
			if string.hasPrefix(self.prefix + suffix) { return true }
		}
		return false
	}
	
	public func parse(comparedTo string: String) -> (next: String, match: String) {
		guard suffixes.count > 0 else { return string.hasPrefix(prefix) ? (string.deletingPrefix(prefix), prefix) : (string, "") }
		for suffix in suffixes {
			let check = self.prefix + suffix
			if string.hasPrefix(check) { return (string.deletingPrefix(check), check) }
		}
		return (string, "")
	}
    
	public init(rawValue: StringLiteralType) {
        self.rawValue = rawValue
        let split = rawValue.split(maxSplits: 1, omittingEmptySubsequences: true, whereSeparator: { $0 == "(" || $0 == ")" } )
        switch split.count {
            case 1: prefix = String(split[0]); suffixes = .init()
			case 2: prefix = String(split[0]); suffixes = split[1].replacing(" ", with: "").split(separator: ",", omittingEmptySubsequences: true).map { $0 == "." ? "" : String( $0 ) }
			default: prefix = rawValue; suffixes = .init()
        }
    }
}

extension CompositeString: ExpressibleByStringLiteral {
	public typealias StringLiteralType = String
	
	public init(stringLiteral: StringLiteralType) {
		self.init(rawValue: stringLiteral)
	}
	
	
}

public typealias CompositeStringDictionaryElement = Dictionary<AnyHashable, CompositeString>.Element

extension Predicate where Target == CompositeStringDictionaryElement {
    public static func hasPrefix(comparedTo string: String) -> Self {
        Predicate { return string.hasPrefix($0.value.prefix) }
    }
        
    public static func hasSuffix(comparedTo string: String) -> Self {
        Predicate { return $0.value.suffixes.contains("?") || $0.value.suffixes.contains(string.eliminatePrefix($0.value.prefix)!) }
    }
    
    public static func equals(comparedTo string: String) -> Self {
        Predicate {
            if string.hasPrefix($0.value.prefix) {
                return $0.value.suffixes.contains("?") ||
                $0.value.suffixes.contains(string.eliminatePrefix($0.value.prefix)!)
            } else { return false }
        }
    }
}

//
//  CompositeStringStringTuples.swift
//
//
//  Created by Thomas Benninghaus on 27.04.24.
//

public struct CompositeStringStringTuples: Sendable {
	public typealias Tuple = (CompositeString, String)
    public let tuples: [Tuple]
    
    public init(tuples: [Tuple]) {
        self.tuples = tuples
    }

    public func first(matching predicate: Predicate<Tuple>) -> Tuple? {
        tuples.first(where: predicate.matches)
    }
}

extension Predicate where Target == CompositeStringStringTuples.Tuple {
	public static func hasPrefix(comparedTo string: String) -> Self {
		Predicate { return $0.0.hasPrefix(comparedTo: string) }
	}
}

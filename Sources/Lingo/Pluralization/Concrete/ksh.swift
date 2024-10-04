import Foundation

public final class ksh: PluralizationRule, @unchecked Sendable {
    public let locale: LocaleIdentifier = "ksh"
    public let availablePluralCategories: [PluralCategory] = [.zero, .one, .other]
    
    public func pluralCategory(forNumericValue n: UInt) -> PluralCategory {
        if n == 0 { return .zero } else 
        if n == 1 { return .one } else { return .other }
    }
}

import Foundation

public final class mt: PluralizationRule, @unchecked Sendable {
    public let locale: LocaleIdentifier = "mt"
    public let availablePluralCategories: [PluralCategory] = [.one, .few, .many, .other]
    
    public func pluralCategory(forNumericValue n: UInt) -> PluralCategory {
        let mod100 = n % 100
        
        if n == 1 { return .one } else if n == 0 || (2...10).contains(mod100) { return .few } else
        if (11...19).contains(mod100) { return .many } else { return .other }
    }
}

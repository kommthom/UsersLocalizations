import Foundation

public final class lv: PluralizationRule, @unchecked Sendable {
    public let locale: LocaleIdentifier = "lv"
    public let availablePluralCategories: [PluralCategory] = [.one, .other]
    
    public func pluralCategory(forNumericValue n: UInt) -> PluralCategory {
        if n % 10 == 1 && n % 100 != 11 { return .one } else { return .other }
    }
}

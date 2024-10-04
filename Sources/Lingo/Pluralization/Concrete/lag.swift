import Foundation

public final class lag: PluralizationRule, @unchecked Sendable {
    public let locale: LocaleIdentifier = "lag"
    public var availablePluralCategories: [PluralCategory] = [.zero, .one, .other]
    
    public func pluralCategory(forNumericValue n: UInt) -> PluralCategory {
        if n == 0 { return .zero } else
        if n > 0 && n < 2 {  return .one } else { return .other }
    }
}

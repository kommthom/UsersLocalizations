import Foundation

public final class gv: PluralizationRule, @unchecked Sendable {
    public let locale: LocaleIdentifier = "gv"
    public let availablePluralCategories: [PluralCategory] = [.one, .other]
    
    public func pluralCategory(forNumericValue n: UInt) -> PluralCategory {
        let mod10 = n % 10
        let mod20 = n % 20
        
        if (1...2).contains(mod10) || mod20 == 0 { return .one } else {  return .other }
    }
}

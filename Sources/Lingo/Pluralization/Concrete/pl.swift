import Foundation

public final class pl: PluralizationRule, @unchecked Sendable {
    public let locale: LocaleIdentifier = "pl"
    public var availablePluralCategories: [PluralCategory] = [.one, .few, .many, .other]
    
    public func pluralCategory(forNumericValue n: UInt) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        
        if n == 1 { return .one } else 
        if  (2...4).contains(mod10) && !(12...14).contains(mod100) { return .few } else
        if (0...1).contains(mod10) || (5...9).contains(mod10) || (12...14).contains(mod100) { return .many} else {return .other}
    }
    
}

//
//  KeyWordType.swift
//  common-localizations
//
//  Created by Thomas Benninghaus on 27.08.24.
//

public struct KeyWordType: Sendable { //: KeyWordTypeProtocol {
	public var type: String
	public var arguments: [String]
}

//public enum KeyWordType: KeyWordTypeProtocol {
//	case repeating //(_ fromCompleted: Bool)
//	case dateTimeSpan //(_ span: DateComponent)
//	case typeOfDay //(_ type: TypeOfDay)
//	case timeOfDay //(_ time: TimeOfDay)
//	case intName //(_ value: Int)
//	case interval //(_ type: IntervalKeyword)
//	case dateInit
//	case listSeparator
//	case filler
//}
//
//public enum IntervalKeyword: IntervalKeyword {
//	case starting, ending, length
//}

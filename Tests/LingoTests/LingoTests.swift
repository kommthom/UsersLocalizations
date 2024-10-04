import XCTest
@testable import Lingo

final class LingoTests: XCTestCase {
    
    let localizationsRootPath = NSTemporaryDirectory().appending("LingoTests")
    
    override func setUp() {
        super.setUp()
        try! DefaultFixtures.setup(atPath: self.localizationsRootPath) // swiftlint:disable:this force_try
    }
    
    func testNonExistingKeyReturnsRawKeyAsLocalization() async throws {
		let lingo = try await Lingo(rootPath: self.localizationsRootPath, defaultLocale: "en")
		let result = await lingo.localize("non.existing.key", locale: "en")
        XCTAssertEqual(result, "non.existing.key")
    }
    
    func testFallbackToDefaultLocale() async throws {
        let lingo = try await Lingo(rootPath: self.localizationsRootPath, defaultLocale: "en")
		let result = await lingo.localize("hello.world", locale: "non-existing-locale")
        XCTAssertEqual(result, "Hello World!")
    }

    func testFallbackToLanguageCodeWhenExactLocaleDoesntExist() async throws {
        let lingo = try await Lingo(rootPath: self.localizationsRootPath, defaultLocale: "en")
		let result = await lingo.localize("unread.messages", locale: "de-CH", interpolations: ["unread-messages-count": 24])
        XCTAssertEqual(result, "Du hast 24 ungelesene Nachrichten.")
    }

    func testLocalizationWithoutInterpolations() async throws {
        let lingo = try await Lingo(rootPath: self.localizationsRootPath, defaultLocale: "en")
		var result = await lingo.localize("hello.world", locale: "en")
        XCTAssertEqual(result, "Hello World!")
		result = await lingo.localize("hello.world", locale: "de")
        XCTAssertEqual(result, "Hallo Welt!")
    }

    func testLocalizationWithInterpolations() async throws {
        let lingo = try await Lingo(rootPath: self.localizationsRootPath, defaultLocale: "en")
		var result = await lingo.localize("unread.messages", locale: "en", interpolations: ["unread-messages-count": 1])
        XCTAssertEqual(result, "You have an unread message.")
		result = await lingo.localize("unread.messages", locale: "en", interpolations: ["unread-messages-count": 24])
        XCTAssertEqual(result, "You have 24 unread messages.")
    }

    func testPluralizationFallbackWhenPluralizationRuleIsMissing() async throws {
        let lingo = try await Lingo(rootPath: self.localizationsRootPath, defaultLocale: "en")
		var result = await lingo.localize("unread.messages", locale: "en-XX", interpolations: ["unread-messages-count": 1])
        XCTAssertEqual(result, "You have an unread message.")
		result = await lingo.localize("unread.messages", locale: "en-XX", interpolations: ["unread-messages-count": 24])
        XCTAssertEqual(result, "You have 24 unread messages.")
    }
}

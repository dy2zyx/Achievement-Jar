import XCTest

final class AchievementEntryViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-uiTestMode"]
        app.launch()
        
        // Navigate to the AchievementEntryView
        // Assuming a '+' button on the main screen opens the sheet
        app.buttons["Add Achievement"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testCharacterLimit_Enforced() throws {
        let textEditor = app.textViews["achievementContentTextEditor"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5), "Text editor should exist")
        
        let longText = String(repeating: "a", count: 650)
        textEditor.tap()
        textEditor.typeText(longText)
        
        // Verify text is truncated in the text editor's value
        let editorValue = textEditor.value as? String ?? ""
        XCTAssertEqual(editorValue.count, 600, "Text should be truncated to 600 characters")
    }
    
    func testCharacterCount_UpdatesCorrectly() throws {
        let textEditor = app.textViews["achievementContentTextEditor"]
        let charCountText = app.staticTexts["characterCountText"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5), "Text editor should exist")
        XCTAssertTrue(charCountText.waitForExistence(timeout: 1), "Character count should exist")

        // Initial state
        XCTAssertEqual(charCountText.label, "0/600")
        
        // Type some text
        textEditor.tap()
        textEditor.typeText("Hello")
        XCTAssertEqual(charCountText.label, "5/600")
        
        // Type long text
        textEditor.typeText(String(repeating: "b", count: 590)) // Total 595
        XCTAssertEqual(charCountText.label, "595/600")
        
        // Try typing past the limit
        textEditor.typeText("abcdefghij") // Should stop at 600
        XCTAssertEqual(charCountText.label, "600/600")
    }
    
    func testAddButton_DisabledWhenEmpty() throws {
        let textEditor = app.textViews["achievementContentTextEditor"]
        let addButton = app.buttons["addToJarButton"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5), "Text editor should exist")
        XCTAssertTrue(addButton.waitForExistence(timeout: 1), "Add button should exist")

        // Ensure text editor is empty (it should be initially)
        let editorValue = textEditor.value as? String ?? ""
        XCTAssertTrue(editorValue.isEmpty, "Text editor should be empty initially")
        
        // Verify button is disabled
        XCTAssertFalse(addButton.isEnabled, "Add button should be disabled when text is empty")
    }
    
    func testAddButton_EnabledWhenNotEmpty() throws {
        let textEditor = app.textViews["achievementContentTextEditor"]
        let addButton = app.buttons["addToJarButton"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5), "Text editor should exist")
        XCTAssertTrue(addButton.waitForExistence(timeout: 1), "Add button should exist")

        // Type some text
        textEditor.tap()
        textEditor.typeText("Valid Achievement")
        
        // Verify button is enabled
        XCTAssertTrue(addButton.isEnabled, "Add button should be enabled when text is not empty")
    }
    
    func testAddButton_DisabledWhenOnlyWhitespace() throws {
        let textEditor = app.textViews["achievementContentTextEditor"]
        let addButton = app.buttons["addToJarButton"]
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5), "Text editor should exist")
        XCTAssertTrue(addButton.waitForExistence(timeout: 1), "Add button should exist")

        // Type only whitespace
        textEditor.tap()
        textEditor.typeText("   \n   ")
        
        // Verify button is disabled
        XCTAssertFalse(addButton.isEnabled, "Add button should be disabled when text is only whitespace")
    }
} 
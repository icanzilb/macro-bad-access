import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import DebounceMacros

let testMacros: [String: Macro.Type] = [
    "debounce": DebounceMacro.self,
]

final class DebounceTests: XCTestCase {
    func testMacroConfig() throws {
        assertMacroExpansion(
            """
            #debounce(debug: true)
            """,
            expandedSource: "", // it seems like the actual generated source here is lost? another bug?
            macros: testMacros
        )

        // need to reset the debug here since it's a global state
        assertMacroExpansion(
            """
            #debounce(debug: false)
            """,
            expandedSource: "", // it seems like the actual generated source here is lost? another bug?
            macros: testMacros
        )
    }

    func testMacroDefaultReturn() throws {
        assertMacroExpansion(
            """
            #debounce(.milliseconds(200))
            """,
            expandedSource: """
            if case Result.failure = await debounce(interval: .milliseconds(200), debug: false) {
              return
            }
            """,
            macros: testMacros
        )
    }

    func testMacroReturnValue() throws {
        assertMacroExpansion(
            """
            #debounce(.milliseconds(200), .return(12345))
            """,
            expandedSource: """
            if case Result.failure = await debounce(interval: .milliseconds(200), debug: false) {
              return(12345)
            }
            """,
            macros: testMacros
        )
    }

    func testMacroThrow() throws {
        assertMacroExpansion(
            """
            #debounce(.milliseconds(200), .throw(MyError()))
            """,
            expandedSource: """
            if case Result.failure = await debounce(interval: .milliseconds(200), debug: false) {
              throw(MyError())
            }
            """,
            macros: testMacros
        )
    }

}

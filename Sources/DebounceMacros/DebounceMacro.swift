import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private(set) public var debugEnabled = false {
    didSet {
        if debugEnabled {
            print("Debounce debug set to \(debugEnabled)")
        }
    }
}

public struct DebounceMacro: DeclarationMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let argument = node.argumentList.first else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        if let labeled = argument.as(LabeledExprSyntax.self),
        labeled.label?.trimmed.text == "debug",
        let value = labeled.expression.as(BooleanLiteralExprSyntax.self) {
            
            debugEnabled = value.trimmed.literal.text == "true"
            
            return [
                "// nothing"
                //"let _: Void = ()"
            ]
        }

        // Bounced expression
        let expression: String
        if node.argumentList.count > 1 {
            let secondArgumentIndex = node.argumentList.index(after: node.argumentList.startIndex)
            var expr = node.argumentList[secondArgumentIndex].expression.description
            if expr.hasPrefix(".throw(") {
                expr.removeFirst(1)
                expression = expr
            } else if expr.hasPrefix(".return(") {
                expr.removeFirst(1)
                expression = expr
            } else {
                print("Debounced expression invalid")
                fatalError("Debounced expression invalid")
            }
        } else {
            expression = "return"
        }

        return [
            """
            if case Result.failure = await debounce(interval: \(raw: argument.expression.description), debug: \(raw: debugEnabled)) {
              \(raw: expression)
            }


            
            """
        ]
    }
}

@main
struct DebouncePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DebounceMacro.self,
    ]
    var debounceDebug = false
}

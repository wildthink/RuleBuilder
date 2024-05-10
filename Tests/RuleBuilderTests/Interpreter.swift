import Foundation
import RuleBuilder

let Nil = Optional<Any>.none as Any

extension RuleEnvironmentValues {
    //    RuleEnvironmentKey
    var engine: Any {
        set {}
        get { Nil }
    }
}

struct Interpreter: Rule {
    
    func room(_ tag: String, @RuleBuilder bob: () -> some Rule) -> some Rule {
        bob()
    }
    
    func room(_ tag: String) -> some Rule {
        EmptyRule()
    }

    // menu, toolbar, actions
    // deck
    func rules() async throws -> some Rule {
        room("Main")
            .ruleEnvironment(\.engine, "")
        //            "Main Scene"
        //        }
        //        .modifier()
        //        .RuleEnvironment(\.remainingPath, .init())
    }
}

struct SomeModifier: RuleModifier {
    func rules(_ content: Content) -> some Rule {
//        "jp"
        EmptyRule()
    }
}

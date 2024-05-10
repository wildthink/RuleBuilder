import Foundation
//@_spi(Experimental)
import RuleBuilder
import SwiftUI

protocol Segue: Rule {}

struct SegueRule<Content: Rule>: Segue {
    var content: (String) -> Content

    func rules() async throws -> some Rule {
        content("")
    }
}

//public struct PathReader<Content: Rule>: BuiltinRule, Rule {
//    var content: (String) -> Content
//    public init(@RuleBuilder content: @escaping (String) -> Content) {
//        self.content = content
//    }
//
//    func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Response? {
//        nil
////        guard let component = RuleEnvironment.remainingPath.first else { return nil }
////        var copy = RuleEnvironment
////        copy.remainingPath.removeFirst()
////        return try await content(component).run(RuleEnvironment: copy)
//    }
//}

func reval() async throws -> String? {
    let bp = Blueprint()
    return try await bp.run(ruleEnvironment: .init())
}

@dynamicMemberLookup
final class Context {
    var values: [String: Any] = [:]
    
    init(values: [String : Any]) {
        self.values = values
    }
    
    subscript<V>(dynamicMember key: String) -> V? {
        get { values[key] as? V }
        set { values[key] = newValue }
    }
}

extension Context: ExpressibleByDictionaryLiteral {
    convenience init(dictionaryLiteral elements: (String, Any)...) {
        let dict = Dictionary(elements, uniquingKeysWith: { $1 })
        self.init(values: dict)
    }
}

infix operator °= : AssignmentPrecedence

func °= <A>(lhs: inout A, rhs: @autoclosure () -> A) -> some Rule {
    EmptyRule()
}

/// Blueprints are Rules that produce/specifiy a body: some View when run
struct Blueprint: Rule {
    
    var ø: Context = [:]
//    var a: Tagged<Int> for expression/context variables
    
    @_disfavoredOverload
    func room(_ tag: String, @RuleBuilder bob: () -> some Rule) -> some Rule {
        bob()
    }
    
    func room(_ tag: String) -> some Segue {
        SegueRule { _ in
            EmptyRule()
        }
//        EmptyRule()
    }

    func ƒ(_ x: Int) -> Int { x }
    let Ø = 0
    let Ω = 0
    // menu, toolbar, actions
    // deck
    func rules() async throws -> some Rule {
//        let ƒ = 12
        room("Home"); room("Home")
        room("Home")
            .presents("alert", mode: .alert) {
                Text("Title")
            }
        ø.x °= 23
        
//        room("Main") {
//            "Main Scene"
//        }
//        .modifier()
//        .RuleEnvironment(\.remainingPath, .init())
    }
}

enum PresentationMode {
    case none
    case sheet
    case alert
    case toast
}

extension Segue {
    func presents(
        _ tag: String,
        `if` cond: () -> Bool = { true },
        mode: PresentationMode,
        @ViewBuilder bob: () -> some View
    ) -> some Rule {
        self
    }

//    func presents(_ tag: String, mode: PresentationMode, @RuleBuilder bob: () -> some Rule) -> some Rule {
//        bob()
//    }
}

struct SimSpan: RuleModifier {
    func rules(_ content: Content) -> some Rule {
         EmptyRule()
    }
}

@propertyWrapper
struct Wrapper<T> {
    var wrappedValue: T
}

struct S {
    private var _value: Wrapper<Int>
    var value: Int {
        @storageRestrictions(initializes: _value)
        init(newValue)  {
            self._value = Wrapper(wrappedValue: newValue)
        }
        // _read, _modify
        get { _value.wrappedValue }
        set { _value.wrappedValue = newValue }
    }
    
    // This initializer is the same as the generated member-wise initializer.
    init(value: Int) {
        self.value = value  // Calls 'init' accessor on 'self.value'
    }
}

@propertyWrapper
struct Shared<Value> {
    
    init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
    
    var _wrappedValue: Value
    var wrappedValue: Value {
        get { _wrappedValue }
        set {
            print("willSet", _wrappedValue)
            _wrappedValue = newValue
            print("didSet", _wrappedValue)
        }
    }
    
}

//extension Shared<Person> {
//    
//    init(wrappedValue: Int, table: String) {
//        _wrappedValue = .init(name: "Alias", age: 10)
//    }
//    
//    init(wrappedValue: Int) {
//        _wrappedValue = .init(name: "Alias", age: 10)
//    }
//}

//protocol Facet {}

// ux (.readOnly, .select, .searchable, .write, .input(control), .execute(action), .trigger(..))
// ux .stepper, .dial, .slider
// ux UsableUnit Usage
// ux prominence
// ux media - text, markdown, attributed text, image, audio, video, av, haptic
// affordance, actor, agent, face, facade, presentation
// cue, prompt
// alert(error, warning, priority/severity), inform(toast), confirm
// morph, re/shape, re/form, re/construct
// re/format , composer, reformer
protocol Composer {
    associatedtype Input
    associatedtype Output
}

/*
 
 Facet - wikipedia_info, imdb, book/goodreads, ...
 affordance
 
 "Tap Me".as(button, do: {})
 "Tap Me".as(link, destination: {})
 */

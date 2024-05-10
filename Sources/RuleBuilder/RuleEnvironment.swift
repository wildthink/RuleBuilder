import Foundation

public protocol RuleEnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

public struct RuleEnvironmentValues {
    @_spi(RuleDeveloper) public var userDefined: [ObjectIdentifier: Any] = [:]

    public init() {
        userDefined = [:]
    }

    public subscript<Key: RuleEnvironmentKey>(key: Key.Type = Key.self) -> Key.Value {
        get { (userDefined[ObjectIdentifier(key)] as? Key.Value) ?? Key.defaultValue }
        set { userDefined[ObjectIdentifier(key)] = newValue }
    }
}

struct RuleEnvironmentWriter<Value, Content: Rule>: BuiltinRule, Rule {
    var keyPath: WritableKeyPath<RuleEnvironmentValues, Value>
    var value: Value
    var content: Content

    func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        var copy = ruleEnvironment
        copy[keyPath: keyPath] = value
        return try await content.run(ruleEnvironment: copy)
    }
}

extension Rule {
    public func ruleEnvironment<Value>(_ keyPath: WritableKeyPath<RuleEnvironmentValues, Value>, _ value: Value) -> some Rule {
        RuleEnvironmentWriter(keyPath: keyPath, value: value, content: self)
    }
}

final class Box<A> {
    var value: A
    init(value: A) {
        self.value = value
    }
}

@propertyWrapper
public struct RuleEnvironment<Value>: DynamicProperty {
    public init(_ keyPath: KeyPath<RuleEnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    var keyPath: KeyPath<RuleEnvironmentValues, Value>
    var box: Box<RuleEnvironmentValues?> = Box(value: nil)

    func install(_ env: RuleEnvironmentValues) {
        box.value = env
    }

    public var wrappedValue: Value {
        guard let env = box.value else {
            fatalError("Using the RuleEnvironment outside of the rules")
        }
        return env[keyPath: keyPath]
    }
}

protocol DynamicProperty {
    func install(_ env: RuleEnvironmentValues)
}

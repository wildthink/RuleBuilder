import Foundation

public protocol Rule {
    associatedtype R: Rule
    @RuleBuilder func rules() async throws -> R
}

extension Never: Rule {
    public func rules() -> some Rule {
        fatalError()
    }
}

//@_spi(RuleDeveloper)
public protocol BuiltinRule {
    func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any?
}

//@_spi(RuleDeveloper)
extension BuiltinRule {
    public func rules() -> Never {
        fatalError()
    }
}

@_spi(RuleDeveloper)
extension RuleEnvironmentValues {
    func install<Target>(on: Target) {
        let m = Mirror(reflecting: on)
        for child in m.children {
            guard let p = child.value as? DynamicProperty else { continue }
            p.install(self)
        }
    }
}

public
func install<Target>(ruleEnvironment: RuleEnvironmentValues, on: Target) {
    let m = Mirror(reflecting: on)
    for child in m.children {
        guard let p = child.value as? DynamicProperty else { continue }
        p.install(ruleEnvironment)
    }
}

extension Rule {
    
    public func run<Output>(ruleEnvironment: RuleEnvironmentValues) async throws -> Output? {
        if let b = self as? BuiltinRule {
            return try await b.execute(ruleEnvironment: ruleEnvironment) as? Output
        }
        install(ruleEnvironment: ruleEnvironment, on: self)
        return try await rules().run(ruleEnvironment: ruleEnvironment)
    }

    @_disfavoredOverload
    public func run(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        if let b = self as? BuiltinRule {
            return try await b.execute(ruleEnvironment: ruleEnvironment)
        }
        install(ruleEnvironment: ruleEnvironment, on: self)

        return try await rules().run(ruleEnvironment: ruleEnvironment)
    }
}

public struct EmptyRule: BuiltinRule, Rule {
    public init() {}
    public func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        nil
    }
}

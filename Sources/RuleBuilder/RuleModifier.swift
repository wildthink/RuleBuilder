public protocol RuleModifier {
    associatedtype Result: Rule
    @RuleBuilder
    func rules(_ content: Content) -> Result
}

public struct Content: Rule, BuiltinRule {
    private var rule: any Rule

    public init<R: Rule>(rule: R) {
        self.rule = rule
    }

    public func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        try await rule.run(ruleEnvironment: ruleEnvironment)
    }
}

struct Modified<R: Rule, M: RuleModifier>: Rule, BuiltinRule {
    var content: R
    var modifier: M

    func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        install(ruleEnvironment: ruleEnvironment, on: modifier)
        return try await modifier
            .rules(.init(rule: content))
            .run(ruleEnvironment: ruleEnvironment)
    }

}

extension Rule {
    public func modifier<M: RuleModifier>(_ modifier: M) -> some Rule {
        Modified(content: self, modifier: modifier)
    }
}

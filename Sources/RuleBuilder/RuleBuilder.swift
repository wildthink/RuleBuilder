import Foundation

@resultBuilder
public struct RuleBuilder {

    public static func buildPartialBlock<R: Rule>(first: R) -> some Rule {
        first
    }
        
    public static func buildPartialBlock<R0: Rule, R1: Rule>(accumulated: R0, next: R1) -> some Rule {
        RulePair(r0: accumulated, r1: next)
    }
    
    public static func buildEither<R0: Rule, R1: Rule>(first component: R0) -> Either<R0, R1> {
        Either<R0, R1>.left(component)
    }
    
    public static func buildEither<R0: Rule, R1: Rule>(second component: R1) -> Either<R0, R1> {
        Either<R0, R1>.right(component)
    }
    
    public static func buildOptional<R: Rule>(_ component: R?) -> R? {
        return component
    }
}

extension Optional: Rule, BuiltinRule where Wrapped: Rule {
    public func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
       try await self?.run(ruleEnvironment: ruleEnvironment)
    }
}

public enum Either<R0: Rule, R1: Rule>: BuiltinRule, Rule {
    case left(R0)
    case right(R1)
    
    public func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        switch self {
            case .left(let r): return try await r.run(ruleEnvironment: ruleEnvironment)
            case .right(let r): return try await r.run(ruleEnvironment: ruleEnvironment)
        }
    }
}

// FIXME: - jmj combine rules in the Response
struct RulePair<R0: Rule, R1: Rule>: Rule {
    var r0: R0
    var r1: R1
}

extension RulePair: BuiltinRule {
    typealias Results = Any
    
    func execute(ruleEnvironment: RuleEnvironmentValues) async throws -> Any? {
        if let r = try await r0.run(ruleEnvironment: ruleEnvironment) {
            return r
        }
        return try await r1.run(ruleEnvironment: ruleEnvironment)
    }
}

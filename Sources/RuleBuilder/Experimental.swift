//
//  Experimental.swift
//
//
//  Created by Jason Jobe on 3/16/24.
//

import Foundation


public struct Response: Hashable, Codable {
    public init(statusCode: Int = 200, body: Data) {
        self.statusCode = statusCode
        self.body = body
    }
    
    public var statusCode: Int = 200
    public var body: Data
}

@_spi(Experimental)
extension Response: Rule, BuiltinRule {
    public func execute(ruleEnvironment: RuleEnvironmentValues) -> Any? {
        return self
    }
}

@_spi(Experimental)
public protocol ToData {
    var toData: Data { get }
}

@_spi(Experimental)
extension RuleBuilder {
    public static func buildPartialBlock<D: ToData>(first: D) -> some Rule {
        Response(body: first.toData)
    }
    
    public static func buildPartialBlock<R0: Rule, R1: ToData>(accumulated: R0, next: R1) -> some Rule {
        RulePair(r0: accumulated, r1: Response(body: next.toData))
    }
}

@_spi(Experimental)
extension String: ToData {
    public var toData: Data {
        data(using: .utf8)!
    }
}

//public struct Request: Hashable, Codable {
//    var path: String
//    // TODO headers, etc.
//
//    public init(path: String) {
//        self.path = path
//    }
//}
//

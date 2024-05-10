//
//  File.swift
//  
//
//  Created by Jason Jobe on 3/17/24.
//

import Foundation
import SwiftUI

#if canImport(Carbon.MID64)
import Carbon.MID64
public typealias EntityID = MID64
public typealias EID = MID64
#else
public typealias EntityID = Int64
public typealias EID = Int64
#endif

public protocol Facet: Identifiable where ID == Int64 {
    var id: Int64 { get }
    var version: ID { get }
    
    static func defaultValue(id: ID) -> Self
}

public extension Facet {
    static var defaultValue: Self { defaultValue(id: 0) }
    var version: ID { 0 }
}

@propertyWrapper
public struct Entity<F: Facet>: DynamicProperty {
    public var wrappedValue: F
    
    public init(wrappedValue: F) {
        self.wrappedValue = wrappedValue
    }
    
    init(projectedValue: Self) {
        self = projectedValue
    }
}

public extension Entity {
    @_disfavoredOverload
    init(wrappedValue: EntityID) {
        self.wrappedValue = F.defaultValue(id: wrappedValue)
    }
}

extension Entity {
    @_disfavoredOverload
    init(wrappedValue: EntityID) where F == Foo {
        self.wrappedValue = F.defaultValue(id: wrappedValue)
    }
}

struct Foo: Facet {
    static func defaultValue(id: Int64) -> Foo {
        Foo(id: id, name: "")
    }
    var id: Int64
    var name: String
}

func example() {
    @Entity var foo: Foo = 0
}

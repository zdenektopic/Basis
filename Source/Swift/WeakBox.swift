//
//  WeakBox.swift
//  Basis
//
//  Created by Topic, Zdenek on 28/12/2017.
//  Copyright © 2017 Zdenek Topic. All rights reserved.
//

public protocol WeakBoxType {
    
    associatedtype BoxedType: AnyObject
    
    var unboxed: BoxedType? { get }
    func unbox(_ closure: (BoxedType) -> Void)
    func map<T>(default: T, _ closure: (BoxedType) -> T) -> T
    
}

public extension WeakBoxType {
    
    public var isNil: Bool {
        return unboxed == nil
    }
    
    public var isNotNil: Bool {
        return !isNil
    }
    
    public func unbox(_ closure: (BoxedType) -> Void) {
        guard let unboxed = unboxed else {
            return
        }
        
        closure(unboxed)
    }
    
    public func map<T>(default: T, _ closure: (BoxedType) -> T) -> T {
        guard let unboxed = unboxed else {
            return `default`
        }
        
        return closure(unboxed)
    }
    
}

public struct WeakBox<BoxedType: AnyObject>: WeakBoxType {
    
    public weak var unboxed: BoxedType?
    
    init(_ object: BoxedType?) {
        self.unboxed = object
    }
    
}

public extension Collection where Self.Element: AnyObject {
    
    public func weakified() -> [WeakBox<Self.Element>] {
        return self.map { return WeakBox($0) }
    }
    
}

public extension Collection where Self.Element: _OptionalType, Self.Element._Wrapped: AnyObject {
    
    public func weakified() -> [WeakBox<Self.Element._Wrapped>] {
        return self.map { return WeakBox($0.value) }
    }
    
}

public extension Collection where Self.Element: WeakBoxType {
    
    public func mapIfNotNil<T>(_ closure: (Self.Element.BoxedType) -> T) -> [T] {
        var mapped = [T]()
        for box in self {
            guard let unboxed = box.unboxed else {
                continue
            }
            
            let item = closure(unboxed)
            mapped.append(item)
        }
        
        return mapped
    }
    
    public func filterNil() -> [Self.Element] {
        return self.filter { $0.isNotNil }
    }
    
    public func filteredAndStrongified() -> [Self.Element.BoxedType] {
        var strong: [Self.Element.BoxedType] = []
        
        for box in self {
            guard let unboxed = box.unboxed else {
                continue
            }
            
            strong.append(unboxed)
        }
        
        return strong
    }
    
    public func strongified() -> [Self.Element.BoxedType?] {
        return self.map { return $0.unboxed }
    }
    
}

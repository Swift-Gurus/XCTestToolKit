//
//  File.swift
//  
//
//  Created by Alex Crowe on 2023-12-15.
import Foundation

extension Array {
    func appended(_ element: Element) -> Self {
       var copy = self
        copy.append(element)
        return copy
    }

    func appended(_ sequence: [Element]) -> Self {
       var copy = self
        copy += sequence
        return copy
    }
    
    func getSafely(at index: Index) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }

    mutating func removedFirstSafely() -> Element? {
        guard !isEmpty else { return nil }
        return self.removeFirst()
    }

}

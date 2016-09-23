//
//  FrequencyMap.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 02/08/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public struct FrequencyMap<T : Hashable> {
  let amount: Int
  let value : HuffmanValue<T>
}

extension Array where Element : Hashable {
  public func removeDuplicates() -> Array {
    return Array(Set(self))
  }
  
  public func countOfElement(_ element : Element) -> Int {
    return self.filter { $0 == element }.count
  }
}

public func createFrequencyMap<T : Hashable>(_ source: [T]) -> [FrequencyMap<T>] {
  return [[FrequencyMap(amount: 1, value: HuffmanValue.terminatingValue)],
    source.removeDuplicates().map {
    FrequencyMap(amount: source.countOfElement($0), value: HuffmanValue.value($0))
    }].flatMap { $0 }
}

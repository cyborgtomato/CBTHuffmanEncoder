//
//  HuffmanTable.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 11/09/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public struct HuffmanTable<T : Equatable> {
  let values : [EncodedValue<T>]
  
  func codeForValue(_ value : T) -> EncodedEntity? {
    return values.filter { item in
      switch item.value {
      case .value(let listValue):
        return value == listValue
      default:
        return false
      }
    }.first
  }
  
  func codeForHuffmanValue(_ value : HuffmanValue<T>) -> EncodedEntity? {
    return values.filter { item in
      switch item.value {
      case .value(_):
        return item.value == value
      case .terminatingValue:
        return value == HuffmanValue.terminatingValue
      case .none:
        return false
      }
      }.first
  }
}

public func +<T>(lhs : HuffmanTable<T>, rhs : HuffmanTable<T>) -> HuffmanTable<T> {
  let values = [lhs.values, rhs.values].flatMap { $0 }
  return HuffmanTable(values: values)
}

private func dictionaryUnion<U, T>(_ left: [U : T], _ right: [U : T]) -> [U : T] {
  var retVal : [U : T] = [:]
  for tuple in ([left, right].flatMap{$0}) {
    retVal.updateValue(tuple.1, forKey: tuple.0)
  }
  return retVal
}

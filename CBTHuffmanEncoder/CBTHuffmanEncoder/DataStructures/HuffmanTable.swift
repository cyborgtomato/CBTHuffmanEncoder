//
//  HuffmanTable.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 11/09/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public enum HuffmanTableErrors : Error {
  case MissingValue
}

public struct HuffmanTable<T : Equatable> where T : Hashable {
  let values : [HuffmanValue<T> : EncodedValue<T>]
  
  public func codeForValue(_ value : T) throws -> EncodedEntity {
    let huffmanValue = HuffmanValue.value(value)
    return try codeForHuffmanValue(huffmanValue)
  }
  
  public func codeForHuffmanValue(_ value : HuffmanValue<T>) throws -> EncodedEntity {
    guard let value = values[value] else {
      throw HuffmanTableErrors.MissingValue
    }
    return value
  }
}

public func +<T>(lhs : HuffmanTable<T>, rhs : HuffmanTable<T>) -> HuffmanTable<T> {
  var values : [HuffmanValue<T> : EncodedValue<T>] = [:]
  for (key, value) in lhs.values {
    values.updateValue(value, forKey: key)
  }
  for (key, value) in rhs.values {
    values.updateValue(value, forKey: key)
  }
  return HuffmanTable(values: values)
}

private func dictionaryUnion<U, T>(_ left: [U : T], _ right: [U : T]) -> [U : T] {
  var retVal : [U : T] = [:]
  for tuple in ([left, right].flatMap{$0}) {
    retVal.updateValue(tuple.1, forKey: tuple.0)
  }
  return retVal
}

public func createEncodedCharacters<T>(_ rootNode : HuffmanTreeNode<T>?) throws -> HuffmanTable<T> {
  switch rootNode {
  case .none: throw HuffmanTreeErrors.treeIsEmpty
  case .some(let node): return try createEncodedCharacters(node)
  }
}

public func createEncodedCharacters<T>(_ rootNode : HuffmanTreeNode<T>) throws -> HuffmanTable<T> {
  return try createEncodedCharacters(rootNode, 0, 0)
}

private func createEncodedCharacters<T>(_ rootNode : HuffmanTreeNode<T>, _ currentLevel : UInt8, _ value: Int32) throws
  -> HuffmanTable<T> {
    if rootNode.isLeaf() {
      switch rootNode.value {
      case .none:
        throw HuffmanTreeErrors.invalidTree
      default:
        return HuffmanTable(values: [rootNode.value : EncodedValue(rootNode.value, currentLevel, value)])
      }
    }
    var leftDictionary : HuffmanTable<T> = HuffmanTable(values: [:])
    var rightDictionary : HuffmanTable<T> = HuffmanTable(values: [:])
    if let leftNode = rootNode.leftNode {
      leftDictionary = try createEncodedCharacters(leftNode, currentLevel + 1, value)
    }
    if let rightNode = rootNode.rightNode {
      rightDictionary = try createEncodedCharacters(rightNode, currentLevel + 1, value + (1 << Int32(currentLevel)))
    }
    return leftDictionary + rightDictionary
}

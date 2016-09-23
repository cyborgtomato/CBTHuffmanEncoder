//
//  HuffmanTreeNode.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 02/08/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public enum HuffmanTreeErrors : Error {
  case treeIsEmpty
  case invalidTree
  case invalidNode
  case invalidSequence
}

public enum HuffmanValue<T> {
  case none
  case value(T)
  case terminatingValue
  
  func getValue() -> T? {
    switch self {
    case .value(let item):
      return item
    default:
      return nil
    }
  }
}

public func ==<T : Equatable>(lhs: HuffmanValue<T>, rhs: HuffmanValue<T>) -> Bool {
  switch (lhs, rhs) {
  case (.value(let leftItem), .value(let rightItem)):
    return leftItem == rightItem
  case (.none, .none):
    return true
  case (.terminatingValue, .terminatingValue):
    return true
  default:
    return false
  }
}

open class HuffmanTreeNode<T> {
  var priority: Int = 0
  var depth : UInt8 = 0
  var value: HuffmanValue<T>
  
  weak var parentNode : HuffmanTreeNode<T>?
  var leftNode : HuffmanTreeNode<T>?
  var rightNode : HuffmanTreeNode<T>?
  
  required public init (value: HuffmanValue<T>, depth: UInt8, priority: Int) {
    self.value = value
    self.depth = depth
    self.priority = priority
  }
  
  convenience init() {
    self.init(value: HuffmanValue.none,
              depth: 0,
              priority: 0)
  }
  
  open func nodeForItem(_ item : UInt8) throws -> HuffmanTreeNode<T> {
    guard let node = item == 0 ? leftNode : rightNode else {
      throw HuffmanTreeErrors.invalidNode
    }
    return node
  }
  
  open func isLeaf() -> Bool {
    return self.leftNode == nil && self.rightNode == nil
  }
  
  open func getValue() throws -> T {
    switch value {
    case .value(let item):
      return item
    default:
      throw HuffmanTreeErrors.invalidNode
    }
  }
  
}

public func createEncodedCharacters<T : Hashable>(_ rootNode : HuffmanTreeNode<T>?) throws -> HuffmanTable<T> {
  switch rootNode {
  case .none: throw HuffmanTreeErrors.treeIsEmpty
  case .some(let node): return try createEncodedCharacters(node)
  }
}

public func createEncodedCharacters<T : Hashable>(_ rootNode : HuffmanTreeNode<T>) throws -> HuffmanTable<T> {
  return try createEncodedCharacters(rootNode, 0, 0)
}

private func createEncodedCharacters<T : Hashable>(_ rootNode : HuffmanTreeNode<T>, _ currentLevel : UInt8, _ value: Int32) throws
  -> HuffmanTable<T> {
    if rootNode.isLeaf() {
      switch rootNode.value {
      case .none:
        throw HuffmanTreeErrors.invalidTree
      default:
        return HuffmanTable(values: [EncodedValue(rootNode.value, currentLevel, value)])
      }
    }
    var leftDictionary : HuffmanTable<T> = HuffmanTable(values: [])
    var rightDictionary : HuffmanTable<T> = HuffmanTable(values: [])
    if let leftNode = rootNode.leftNode {
      leftDictionary = try createEncodedCharacters(leftNode, currentLevel + 1, value)
    }
    if let rightNode = rootNode.rightNode {
      rightDictionary = try createEncodedCharacters(rightNode, currentLevel + 1, value + (1 << Int32(currentLevel)))
    }
    return leftDictionary + rightDictionary
}

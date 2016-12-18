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

public enum HuffmanValue<T : Hashable> : Hashable {
  case none
  case value(T)
  case terminatingValue
  
  public func unwrap() -> T? {
    switch self {
    case .value(let item):
      return item
    default:
      return nil
    }
  }
  
  public func forceUnwrap() throws -> T {
    switch self {
    case .value(let item):
      return item
    default:
      throw HuffmanTreeErrors.invalidNode
    }
  }
  
  public func isTerminal() -> Bool {
    switch self {
    case .terminatingValue:
      return true
    default:
      return false
    }
  }
  
  public var hashValue: Int {
    switch self {
    case .value(let item):
      return item.hashValue + 2
    case .none:
      return 0
    case .terminatingValue:
      return 1
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

public class HuffmanTreeNode<T : Hashable> {
  var priority: Int = 0
  var depth : UInt8 = 0
  var valueVar: HuffmanValue<T>
  
  weak var parentNode : HuffmanTreeNode<T>?
  var leftNode : HuffmanTreeNode<T>?
  var rightNode : HuffmanTreeNode<T>?
  
  required public init (value: HuffmanValue<T>, depth: UInt8, priority: Int) {
    self.valueVar = value
    self.depth = depth
    self.priority = priority
  }
  
  convenience public init() {
    self.init(value: HuffmanValue.none,
              depth: 0,
              priority: 0)
  }
  
  public var value : HuffmanValue<T> {
    get {
      return valueVar
    }
  }
  
  public func getLeftNode() throws -> HuffmanTreeNode<T> {
    guard let node = leftNode else {
      throw HuffmanTreeErrors.invalidNode
    }
    return node
  }
  
  public func getRightNode() throws -> HuffmanTreeNode<T> {
    guard let node = rightNode else {
      throw HuffmanTreeErrors.invalidNode
    }
    return node
  }
  
  public func nodeForItem(_ item : UInt8) throws -> HuffmanTreeNode<T> {
    guard let node = item == 0 ? leftNode : rightNode else {
      throw HuffmanTreeErrors.invalidNode
    }
    return node
  }
  
  public func isLeaf() -> Bool {
    return self.leftNode == nil && self.rightNode == nil
  }
  
}

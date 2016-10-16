//
//  HuffmanTree.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 02/08/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public func createFullTree<T>(_ nodes : [HuffmanTreeNode<T>]) -> HuffmanTreeNode<T> {
  var sortedNodes = nodes.sorted {left, right in left.priority < right.priority}
  while sortedNodes.count > 1 {
    let newNode = mergeTwoNodesAndFormParent(sortedNodes[0], rightNode: sortedNodes[1])
    sortedNodes.removeFirst(2)
    var i = 0
    while (i < sortedNodes.count && sortedNodes[i].priority < newNode.priority) {
      i += 1
    }
    sortedNodes.insert(newNode, at: i)
  }
  return sortedNodes[0]
}
  
private func mergeTwoNodesAndFormParent<T>(_ leftNode : HuffmanTreeNode<T>, rightNode : HuffmanTreeNode<T>)
  -> HuffmanTreeNode<T> {
    let parentNode = HuffmanTreeNode<T>(value: HuffmanValue.none,
                                        depth: max(leftNode.depth, rightNode.depth),
                                        priority: leftNode.priority + rightNode.priority)
    parentNode.leftNode = leftNode
    parentNode.rightNode = rightNode
    leftNode.parentNode = parentNode
    rightNode.parentNode = parentNode
    return parentNode;
}

public func createTreeFromTable<T>(_ huffmanTable : [EncodedValue<T>]) -> HuffmanTreeNode<T> {
  let rootNode = HuffmanTreeNode<T>()
  for tableItem in huffmanTable {
    let copy = EncodedEntitySequence(entity: tableItem)
    var currentElement = rootNode;
    for bit in copy {
      if (bit == 0) {
        if (currentElement.leftNode == nil) {
          currentElement.leftNode = HuffmanTreeNode()
          currentElement.leftNode!.parentNode = currentElement
        }
        currentElement = currentElement.leftNode!
      } else {
        if (currentElement.rightNode == nil) {
          currentElement.rightNode = HuffmanTreeNode()
          currentElement.rightNode!.parentNode = currentElement
        }
        currentElement = currentElement.rightNode!
      }
    }
    currentElement.valueVar = tableItem.value
    currentElement = rootNode;
  }
  return rootNode;
}

public func createTreeWithFrequencies<T : Hashable>(_ frequencies: [FrequencyMap<T>]) -> HuffmanTreeNode<T> {
  let nodes = frequencies.map {
    HuffmanTreeNode<T>(value: $0.value, depth: 1, priority: $0.amount)
  }
  return createFullTree(nodes)
}

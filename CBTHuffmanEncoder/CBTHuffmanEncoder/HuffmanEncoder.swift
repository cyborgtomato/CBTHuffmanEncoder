//
//  HuffmanEncoder.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 09/08/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public func encodeBytesWithTermination<T>(_ source: [T], table:HuffmanTable<T>) throws -> [EncodedEntity] {
  let terminatingValue = try table.codeForHuffmanValue(HuffmanValue.terminatingValue)
  return [try source.map { item -> EncodedEntity in
    return try table.codeForValue(item)
    }, [terminatingValue]].flatMap { $0 }
}

public func encodeBytes<T>(_ source: [T], table:HuffmanTable<T>) throws -> [EncodedEntity] {
  return try source.map { item -> EncodedEntity in
    return try table.codeForValue(item)
  }
}

public func saveEncodedDataToByteArray(_ source: [EncodedEntity]) -> [UInt8] {
  var currentShift : UInt8 = 0
  var currentByte : UInt8 = 0
  var retVal : [UInt8] = []
  for entity in source {
    for bit in EncodedEntitySequence(entity: entity) {
      currentByte += (bit << currentShift)
      currentShift += 1
      if currentShift >= 8 {
        currentShift = 0
        retVal.append(currentByte)
        currentByte = 0
      }
    }
  }
  if currentShift > 0 {
    retVal.append(currentByte)
  }
  return retVal
}

public func decodeBytes<T>(_ source: [UInt8], huffmanTree: HuffmanTreeNode<T>) throws -> [T] {
  var currentLength : UInt8 = 0
  var currentNode = huffmanTree
  var retVal : [T] = []
  for character in source {
    for bit in ByteSequence(byte: character) {
      currentLength += 1
      currentNode = try currentNode.nodeForItem(bit)
      if currentNode.isLeaf() {
        switch currentNode.value {
        case .value(let item):
          retVal.append(item)
          currentLength = 0
          currentNode = huffmanTree
        case .terminatingValue:
          return retVal
        case .none:
          throw HuffmanTreeErrors.invalidNode
        }
      }
    }
  }
  return retVal
}

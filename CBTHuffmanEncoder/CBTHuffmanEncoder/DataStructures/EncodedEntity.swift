//
//  EncodedEntity.swift
//  SwiftImageEncoder
//
//  Created by Sergei Smagleev on 08/08/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

public class EncodedEntityGenerator : IteratorProtocol {
  
  public typealias Element = UInt8
  
  var currentIndex : Int32 = 0
  let encodedValue : Int32
  let codeLength : UInt8
  
  public init (encodedValue : Int32, codeLength : UInt8) {
    self.encodedValue = encodedValue
    self.codeLength = codeLength
  }
  
  public func next() -> EncodedEntityGenerator.Element? {
    if (UInt8(currentIndex) < codeLength) {
      let val = UInt8((encodedValue & (1 << currentIndex)) >> currentIndex)
      currentIndex += 1
      return val
    }
    return nil
  }
}

public class EncodedEntitySequence : Sequence {
  
  public typealias Iterator = EncodedEntityGenerator
  
  var currentIndex : Int32 = 0
  
  let entity : EncodedEntity
  
  public init(entity : EncodedEntity) {
    self.entity = entity
  }
  
  public func makeIterator() -> EncodedEntitySequence.Iterator {
    return EncodedEntityGenerator(encodedValue: entity.encodedValue, codeLength: entity.codeLength)
  }
}

public class ByteSequence : Sequence {
  
  public typealias Iterator = EncodedEntityGenerator
  
  let byte : UInt8
  
  init (byte : UInt8) {
    self.byte = byte
  }
  
  public func makeIterator() -> ByteSequence.Iterator {
    return EncodedEntityGenerator(encodedValue: Int32(byte), codeLength: 8)
  }
}

public class EncodedEntity {
  
  var codeLength : UInt8 = 0
  var encodedValue : Int32 = 0
  
  static func empty() -> EncodedEntity {
    return EncodedEntity(codeLength: 0, encodedValue: 0)
  }
  
  required public init(codeLength : UInt8, encodedValue : Int32) {
    self.codeLength = codeLength
    self.encodedValue = encodedValue
  }
  
  func binaryPrintout() -> String {
    var retVal : String = ""
    var mutableValue = encodedValue
    for _ in 1...self.codeLength {
      let bit = mutableValue & 1
      retVal = String(bit) + retVal
      mutableValue >>= 1
    }
    return retVal
  }
}

public class EncodedValue<T> : EncodedEntity {
  var value : HuffmanValue<T>
  var pathString : String
  
  required public init(_ value: HuffmanValue<T>, _ codeLength : UInt8, _ encodedValue : Int32) {
    self.value = value
    pathString = ""
    super.init(codeLength: codeLength, encodedValue: encodedValue)
  }
  
  public init (value : HuffmanValue<T>, stringRepresentation : String) {
    self.value = value
    pathString = stringRepresentation
    var value = 0
    var count = 0
    for character in stringRepresentation.characters {
      value += character == "1" ? (1 << count) : 0
      count += 1
    }
    super.init(codeLength: UInt8(stringRepresentation.characters.count), encodedValue: Int32(value))
  }
  
  required public init(codeLength: UInt8, encodedValue: Int32) {
    fatalError("init(codeLength:encodedValue:) has not been implemented")
  }
}

//
//  CBTHuffmanEncoderTests.swift
//  CBTHuffmanEncoderTests
//
//  Created by Sergei Smagleev on 17/09/16.
//  Copyright © 2016 sergeysmagleev. All rights reserved.
//

import XCTest
import Foundation
@testable import CBTHuffmanEncoder

class CBTHuffmanEncoderTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testStringEncoding(string : String) {
    
    let fileBytes, encodedBytes, decodedBytes : [UInt8]
    
    guard let data = string.data(using: String.Encoding.utf8) else {
      XCTFail("Unable to convert NSString to NSData")
      return
    }
    var byteArray = [UInt8](repeating: 0, count: data.count)
    data.copyBytes(to: &byteArray, count: data.count * MemoryLayout<UInt8>.size)
    fileBytes = byteArray
    
    let frequencies = createFrequencyMap(fileBytes)
    let tree = createTreeWithFrequencies(frequencies)
    
    do {
      encodedBytes = try encode(fileBytes, huffmanTree: tree)
    } catch let error {
      XCTFail("Unable to encode data. Error: \(error)")
      return
    }
    
    if (fileBytes.count > 1) {
      let ratio = Float(encodedBytes.count) / Float(fileBytes.count)
      XCTAssertLessThan(ratio, 1.0)
    }
    
    do {
      decodedBytes = try decode(encodedBytes, huffmanTree: tree)
    } catch let error {
      XCTFail("Unable to decode data. Error: \(error)")
      return
    }
    
    let decodedData = NSData(bytes: decodedBytes, length: decodedBytes.count * MemoryLayout<UInt8>.size)
    let decodedString = String(data: decodedData as Data, encoding: String.Encoding.utf8)
    
    XCTAssertEqual(string, decodedString)
  }
  
  func encode(_ bytes : [UInt8], huffmanTree: HuffmanTreeNode<UInt8>) throws -> [UInt8] {
    let encodeMap = try createEncodedCharacters(huffmanTree)
    let data = try encodeBytesWithTermination(bytes, table: encodeMap)
    return saveEncodedDataToByteArray(data)
  }
  
  func decode(_ bytes : [UInt8], huffmanTree: HuffmanTreeNode<UInt8>) throws -> [UInt8] {
    let decodedBytes = try decodeBytes(bytes, huffmanTree: huffmanTree)
    return decodedBytes
  }
  
  func testEnglishString() {
    self.testStringEncoding(string: "This is a test string to encode")
  }
  
  func testFrenchString() {
    testStringEncoding(string: "ANTOINE DE SAINT-EXUPÉRY (1900-1944). Intensément impliqué dans les premières années de l´aviation commerciale, ses romans sont intimement liés à ses expériences en tant que pilote. Employé par la compagnie Latécoère, il s´en chargera du courrier de Toulouse au Sénégal, parcours qui se prolongera jusqu´en Amérique du Sud en 1929.")
  }
  
  func testEmoji() {
    testStringEncoding(string: "🙂🙃🙂🙃🙂🙃🙂🙃🙂🙃🙂🙃")
  }
  
  func testEmptyString() {
    testStringEncoding(string: "")
  }
  
  func testOneCharacterString() {
    testStringEncoding(string: "a")
  }
  
  func testTwoCharacterString() {
    testStringEncoding(string: "aa")
  }
  
  func testHomogeneousString() {
    testStringEncoding(string: "ggggggg")
  }
  
  func testLongText() {
    let string = "Lorem ipsum dolor sit amet, amet pede consequat aliquam quisque suspendisse nulla, vestibulum dictum mauris ipsum tellus, velit ipsum in vitae mi egestas, fusce in, sem vitae est vel lectus. Potenti etiam sociis aliquam aliquam, laoreet consequat ligula vel, tincidunt malesuada condimentum, cum dolor eleifend nec amet. Faucibus velit velit penatibus ullamcorper sit ipsum, metus erat, euismod sed pede sit iaculis sed tellus, erat arcu volutpat pharetra ultricies viverra, ut massa id viverra tincidunt a. Et libero mattis, amet sociis dolor amet voluptate urna. Sed ut metus, consequat semper, accumsan non sed egestas, facilisis augue aliquet nonummy ac. Tincidunt malesuada sit id quam pellentesque, dolor euismod fringilla donec dolor tellus turpis, pede malesuada sed quam facilisi lorem, ut tristique dignissim mollis, imperdiet laudantium porttitor condimentum metus vel. Purus amet tristique erat sociis proin, malesuada bibendum vitae habitasse adipiscing. Sed dolor neque lacus ut et nunc, nunc vel. Mauris donec vivamus nulla malesuada integer fermentum, ante rhoncus et mauris ad phasellus odio, ornare lectus enim adipiscing libero. Sem dictumst mauris id vivamus ligula at, non ut morbi euismod consectetuer wisi pharetra.\r\n" +
      "Lacinia vel libero lacinia, at ullamcorper suspendisse et, risus lacus tortor pellentesque. Posuere vitae sit pellentesque vivamus, eget vestibulum duis, id ante platea nulla eros. Nibh sed velit ipsum malesuada, neque interdum nam pulvinar proin. Eget tincidunt lacus elit non, et non turpis in amet rutrum sed, vel suspendisse suspendisse, in in vitae sed curabitur, ullamcorper ipsum. Vestibulum lacus mauris molestie porttitor, suspendisse iure, sed aptent, ornare et sit at tempus parturient. Rhoncus a ante, risus tortor sed quis eu, lacus augue, eleifend semper mi aliquam, scelerisque irure venenatis auctor eu rutrum. Ac eros tempus, maecenas urna lorem nulla, integer pede vitae aliquam. Aliquet sed et vestibulum lorem non, augue wisi nec wisi diam eleifend massa. Aliquam non sapien, lorem class sodales parturient donec libero ultrices, curabitur nisl vitae dolor elit.\r\n" +
      "Et vitae scelerisque elit eu volutpat nunc, est voluptas fames auctor. Tristique sed phasellus sit, et lectus tortor lacinia, proin vivamus dui cursus velit diam, quam mi facilisi quam augue augue. Natoque sollicitudin sed, aliquam rutrum dictum praesent felis est mauris, elementum vitae nec neque leo, gravida bibendum nec sed suspendisse lorem wisi, faucibus posuere ullamcorper. Odio commodo et rutrum risus accumsan amet, arcu at congue, phasellus ante suscipit, urna pellentesque aliquam. Tellus wisi rutrum libero fringilla, eu eu sed ullamcorper mauris euismod. In maecenas mi id in, ante tincidunt lobortis arcu nunc donec, lobortis amet sed donec.\r\n" +
    "Interdum quisque magna suscipit aliquam, elit sed maecenas eu amet suscipit, lectus pellentesque aenean cras iste ut, vel leo vel imperdiet sit ac. Ut sed nulla pulvinar magna elementum amet, pellentesque ante per maecenas hendrerit nec curabitur. Vitae turpis vestibulum a pellentesque, vel at nulla venenatis justo elit. Quis voluptatibus at suscipit, lorem enim a adipiscing nunc eu, vestibulum pellentesque gravida et cras nullam quisque, fermentum sagittis blandit ut sit, felis wisi ut proin. Orci libero sit nec gravida integer hymenaeos, orci sit tristique nullam sed sed, justo pede cras quisque integer at, donec nonummy tincidunt eu. Arcu curabitur, litora sem dapibus quo magna interdum aliquam. Libero placerat condimentum augue, erat proin, est orci ornare cras. Accumsan elit in, nobis libero ac massa maecenas ligula, wisi venenatis parturient, risus platea. Nec velit nec wisi."
    measure {
      self.testStringEncoding(string: string)
    }
  }
    
}

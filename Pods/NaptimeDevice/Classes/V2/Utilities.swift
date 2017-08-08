//
//  Utilities.swift
//  NaptimeDevice
//
//  Created by PointerFLY on 03/06/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit

#if OPEN_PRODUCT
    struct V2 {

        static func caculateChecksum(_ value: Int) -> [UInt8] {
            let checksum = (1 << 16 - 1) - (value % (1 << 16))
            return [UInt8(checksum / (1 << 8)), UInt8(checksum % (1 << 8))]
        }

        static func caculateChecksum(length: [UInt8], type: [UInt8], payload: [UInt8]) -> [UInt8] {
            var sum = 0
            for v in length { sum += Int(v) }
            for v in type { sum += Int(v) }
            for v in payload { sum += Int(v) }
            let checksum = (1 << 16 - 1) - (sum % (1 << 16))
            return [UInt8(checksum / (1 << 8)), UInt8(checksum % (1 << 8))]
        }

        static func escape(_ bytes: inout [UInt8])  {
            var i = 2
            while i < bytes.count - 2 {
                if bytes[i] == 0xAA || bytes[i] == 0xCC || bytes[i] == 0xBB {
                    bytes.insert(0xBB, at: i)
                    i += 1
                }
                i += 1
            }
        }

        static func descape(_ bytes: inout [UInt8]) {
            var i = 2
            while i < bytes.count - 2 {
                if bytes[i] == 0xBB {
                    bytes.remove(at: i)
                }
                i += 1
            }
        }

        static func swapEndian(_ bytes: inout [UInt8]) {
            for i in stride(from: 0, through: bytes.count - 2, by: 2) {
                let temp = bytes[i]
                bytes[i] = bytes[i + 1]
                bytes[i + 1] = temp
            }
        }
    }
#else
    public struct V2 {

        public static func caculateChecksum(_ value: Int) -> [UInt8] {
            let checksum = (1 << 16 - 1) - (value % (1 << 16))
            return [UInt8(checksum / (1 << 8)), UInt8(checksum % (1 << 8))]
        }

        public static func caculateChecksum(length: [UInt8], type: [UInt8], payload: [UInt8]) -> [UInt8] {
            var sum = 0
            for v in length { sum += Int(v) }
            for v in type { sum += Int(v) }
            for v in payload { sum += Int(v) }
            let checksum = (1 << 16 - 1) - (sum % (1 << 16))
            return [UInt8(checksum / (1 << 8)), UInt8(checksum % (1 << 8))]
        }

        public static func escape(_ bytes: inout [UInt8])  {
            var i = 2
            while i < bytes.count - 2 {
                if bytes[i] == 0xAA || bytes[i] == 0xCC || bytes[i] == 0xBB {
                    bytes.insert(0xBB, at: i)
                    i += 1
                }
                i += 1
            }
        }

        public static func descape(_ bytes: inout [UInt8]) {
            var i = 2
            while i < bytes.count - 2 {
                if bytes[i] == 0xBB {
                    bytes.remove(at: i)
                }
                i += 1
            }
        }

        public static func swapEndian(_ bytes: inout [UInt8]) {
            for i in stride(from: 0, through: bytes.count - 2, by: 2) {
                let temp = bytes[i]
                bytes[i] = bytes[i + 1]
                bytes[i + 1] = temp
            }
        }
    }
#endif

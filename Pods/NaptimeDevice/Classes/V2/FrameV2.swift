//
//  FrameV2.swift
//  Naptime
//
//  Created by PointerFLY on 02/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

#if OPEN_PRODUCT
    struct FrameV2 {
        let header: [UInt8]
        let length: [UInt8] // 2 bytes
        let type: [UInt8]   // 2 bytes
        let payload: [UInt8]
        let checksum: [UInt8]   // 2 bytes
        let end: [UInt8]

        let isChecksumCorrect: Bool

        var bytes: [UInt8] {
            return header + length + type + payload + checksum + end
        }

        static let kHeader: [UInt8] = [0xCC, 0xAA]
        static let kEnd: [UInt8] = [0xAA, 0xCC]
    }
#else
    public struct FrameV2 {
        public let header: [UInt8]
        public let length: [UInt8] // 2 bytes
        public let type: [UInt8]   // 2 bytes
        public let payload: [UInt8]
        public let checksum: [UInt8]   // 2 bytes
        public let end: [UInt8]

        public let isChecksumCorrect: Bool

        public var bytes: [UInt8] {
            return header + length + type + payload + checksum + end
        }

        public static let kHeader: [UInt8] = [0xCC, 0xAA]
        public static let kEnd: [UInt8] = [0xAA, 0xCC]
    }
#endif

public enum InstructionV2 {
    case startSampling
    case stopSampling
    case requestDeviceInfo
    case requestFirmwareVersion
    case updateDeviceInfo
    case sendDeviceInfo([UInt8])
    case updateFirmware
    case sendFirmware([UInt8])
    case custom([UInt8])

    #if OPEN_PRODUCT
    var bytes: [UInt8] {
        switch self {
        case .startSampling: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x03, 0x00, 0x01, 0xFF, 0xD6] + FrameV2.kEnd
        case .stopSampling: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x03, 0x00, 0x02, 0xFF, 0xD5] + FrameV2.kEnd
        case .requestDeviceInfo: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x01, 0x00, 0x01, 0xFF, 0xD8] + FrameV2.kEnd
        case .requestFirmwareVersion: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x06, 0x00, 0x01, 0xFF, 0xD3] + FrameV2.kEnd
        case .updateDeviceInfo: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x01, 0x00, 0x02, 0xFF, 0xD7] + FrameV2.kEnd
        case .sendDeviceInfo(let bytes):
            let type: [UInt8] = [0x22, 0x01]
            let length: [UInt8] = [UInt8((bytes.count + type.count) >> 8), UInt8((bytes.count + type.count) % 256)]
            let checksum = V2.caculateChecksum(length: length, type: type, payload: bytes)
            return FrameV2.kHeader + length + type + bytes + checksum + FrameV2.kEnd
        case .updateFirmware: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x02, 0x00, 0x02, 0xFF, 0xD6] + FrameV2.kEnd
        case .sendFirmware(let bytes):
            var byts = bytes
            // 固件无大小端，特殊处理
            V2.swapEndian(&byts)
            let type: [UInt8] = [0x22, 0x02]
            let length: [UInt8] = [UInt8((byts.count + type.count) >> 8), UInt8((byts.count + type.count) % 256)]
            let checksum = V2.caculateChecksum(length: length, type: type, payload: byts)
            return FrameV2.kHeader + length + type + byts + checksum + FrameV2.kEnd
        case .custom(let bytes): return bytes
        }
    }
    #else
    public var bytes: [UInt8] {
        switch self {
        case .startSampling: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x03, 0x00, 0x01, 0xFF, 0xD6] + FrameV2.kEnd
        case .stopSampling: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x03, 0x00, 0x02, 0xFF, 0xD5] + FrameV2.kEnd
        case .requestDeviceInfo: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x01, 0x00, 0x01, 0xFF, 0xD8] + FrameV2.kEnd
        case .requestFirmwareVersion: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x06, 0x00, 0x01, 0xFF, 0xD3] + FrameV2.kEnd
        case .updateDeviceInfo: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x01, 0x00, 0x02, 0xFF, 0xD7] + FrameV2.kEnd
        case .sendDeviceInfo(let bytes):
            let type: [UInt8] = [0x22, 0x01]
            let length: [UInt8] = [UInt8((bytes.count + type.count) >> 8), UInt8((bytes.count + type.count) % 256)]
            let checksum = V2.caculateChecksum(length: length, type: type, payload: bytes)
            return FrameV2.kHeader + length + type + bytes + checksum + FrameV2.kEnd
        case .updateFirmware: return FrameV2.kHeader + [0x00, 0x04, 0x21, 0x02, 0x00, 0x02, 0xFF, 0xD6] + FrameV2.kEnd
        case .sendFirmware(let bytes):
            var byts = bytes
            // 固件无大小端，特殊处理
            V2.swapEndian(&byts)
            let type: [UInt8] = [0x22, 0x02]
            let length: [UInt8] = [UInt8((byts.count + type.count) >> 8), UInt8((byts.count + type.count) % 256)]
            let checksum = V2.caculateChecksum(length: length, type: type, payload: byts)
            return FrameV2.kHeader + length + type + byts + checksum + FrameV2.kEnd
        case .custom(let bytes): return bytes
        }
    }
    #endif
}

public enum ResponseV2 {
    case sampledData([UInt8], [UInt8])
    case deviceInfo([UInt8])
    case firmwareVersion([UInt8])
    case click(ClickType)
    case ok
    case unknown

    public enum ClickType {
        case single
        case double
        case up
        case down
    }
}

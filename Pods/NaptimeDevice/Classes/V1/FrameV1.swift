//
//  FrameV1.swift
//  Naptime
//
//  Created by PointerFLY on 02/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public struct FrameV1 {
    public let header: [UInt8]
    public let length: [UInt8]
    public let type: UInt8
    public let sequence: [UInt8]
    public let payload: [UInt8]
    public let checksum: UInt8

    public let isChecksumCorrect: Bool

    public var bytes: [UInt8] {
        return header + length + [type] + sequence + payload + [checksum]
    }

    public static let kHeader: [UInt8] = [0xAA, 0xAA]
}

public enum InstructionV1 {
    case wakeup
    case requestDeviceID
    case startTransmission
    case stopTransmission
    case custom([UInt8])

    public var bytes: [UInt8] {
        switch self {
        case .wakeup: return FrameV1.kHeader + [0x00, 0x01, 0xFB, 0x04]
        case .requestDeviceID: return FrameV1.kHeader + [0x00, 0x01, 0xAA, 0x55]
        case .startTransmission: return FrameV1.kHeader +  [0x00, 0x01, 0xFE, 0x01]
        case .stopTransmission: return FrameV1.kHeader + [0x00, 0x01, 0xFD, 0x02]
        case .custom(let bytes): return bytes
        }
    }
}

public enum ResponseV1 {
    case brainWave(Int, [UInt8])
    case deviceID([UInt8])
    case wakenUp
    case unknown
}

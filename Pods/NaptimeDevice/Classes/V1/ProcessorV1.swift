//
//  ProcessorV1.swift
//  Naptime
//
//  Created by PointerFLY on 02/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

class ProcessorV1 {

    private var _buffer = [UInt8]()
    private var _bodyLength = 0

    func process(bytes: [UInt8]) -> (ResponseV1, FrameV1)? {
        var result: (ResponseV1, FrameV1)?
        var isFrameEnd = false

        for i in 0..<bytes.count {
            let thisByte = bytes[i]

            _buffer.append(thisByte)
            let size = _buffer.count

            if size == 2 {
                let firstByte = _buffer[0]
                if firstByte == FrameV1.kHeader[0] && thisByte == FrameV1.kHeader[1] {
                } else {
                    _buffer.remove(at: 0)
                }
            } else if size == 4 {
                _bodyLength = Int(_buffer[2]) * 256 + Int(thisByte)
            } else if size == 4 + _bodyLength + 1 {
                isFrameEnd = true
            }

            if isFrameEnd {
                result = postProcess(bytes: _buffer)

                isFrameEnd = false
                _buffer.removeAll()
                _bodyLength = 0
            } else if size > 2 {
                let lastSecondByte = _buffer[size - 2]
                if lastSecondByte == FrameV1.kHeader[0] && thisByte == FrameV1.kHeader[1] {
                    _ = _buffer.popLast()
                    _ = _buffer.popLast()

                    result = postProcess(bytes: _buffer)

                    isFrameEnd = false
                    _buffer.removeAll()
                    _bodyLength = 0

                    _buffer.append(contentsOf: FrameV1.kHeader)
                }
            }
        }

        return result
    }

    func postProcess(bytes: [UInt8]) -> (ResponseV1, FrameV1)? {
        // 最小长度检测
        guard bytes.count >= 6 else { return nil }
        // 长度不匹配丢弃
        let length = Int(bytes[2]) * 256 + Int(bytes[3])
        guard length == bytes.count - 5 else { return nil}

        // 计算 checksum 是否正确
        var temp = 0
        for byte in bytes {
            temp += Int(byte)
        }
        let checksumCorrect = ((Int(FrameV1.kHeader[0]) + Int(FrameV1.kHeader[1]) - temp) % 256 == 0)

        var response: ResponseV1?
        var frame: FrameV1?

        switch bytes[4] {
        case 0x00:
            // 根据协议约束长度，长度不正确的帧丢弃
            guard bytes.count == 521 else { return nil }
            frame = FrameV1(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: bytes[4],
                            sequence: Array(bytes[5..<8]),
                            payload: Array(bytes[8..<520]),
                            checksum: bytes[520],
                            isChecksumCorrect: checksumCorrect)

            let sequence = Int(bytes[5]) + Int(bytes[6]) + Int(bytes[7])
            response = ResponseV1.brainWave(sequence, frame!.payload)

        case 0xFA:
            // 根据协议约束长度，长度不正确的帧丢弃
            guard bytes.count == 21 else { return nil }
            frame = FrameV1(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: bytes[4],
                            sequence: Array(bytes[5..<8]),
                            payload: Array(bytes[8..<20]),
                            checksum: bytes[20],
                            isChecksumCorrect: checksumCorrect)

            response = ResponseV1.deviceID(frame!.payload)

        case 0xFC:
            // 根据协议约束长度，长度不正确的帧丢弃
            guard bytes.count == 6 else { return nil }
            frame = FrameV1(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: bytes[4],
                            sequence: [],
                            payload: [],
                            checksum: bytes[5],
                            isChecksumCorrect: checksumCorrect)
            response = ResponseV1.wakenUp

        default:
            // unknown 帧数据全部放到 payload 里
            frame = FrameV1(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: bytes[4],
                            sequence: [],
                            payload: Array(bytes[5..<bytes.count - 1]),
                            checksum: bytes[bytes.count - 1],
                            isChecksumCorrect: checksumCorrect)
            response = ResponseV1.unknown
        }
        
        return (response!, frame!)
    }
}

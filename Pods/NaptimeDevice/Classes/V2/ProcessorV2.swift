//
//  ProcessorV2.swift
//  Naptime
//
//  Created by PointerFLY on 02/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

class ProcessorV2 {

    private var _buffer = [UInt8]()
    private var _isFrameBegin = false

    init() {
        _buffer.reserveCapacity(1024)
    }

    /**
     * 处理流程：
     * 1. _buffer 增加 byte； 
     * 2. 如果组成前缀，那么开始追踪，且移除前缀前的 bytes
     * 3. 如果组成后缀且已有前缀，那么成帧进行 postProcess，然后移除所有的bytes，停止追踪
     * 4. 如果以上都不满足，忽略
     * 5. 从 1 重新开始，直到本次 bytes 序列都被遍历
     */
    func process(bytes: [UInt8]) -> [(response: ResponseV2, frame: FrameV2)] {
        var results = [(ResponseV2, FrameV2)]()
        var i = 0
        while i < bytes.count {
            let pre = _buffer.last
            let cur = bytes[i]

            _buffer.append(cur)

            if pre == 0xAA && cur == 0xCC {
                _isFrameBegin = true
                _buffer.removeSubrange(0..<(_buffer.count - 2))
            } else if pre == 0xCC && cur == 0xAA {
                if _isFrameBegin {
                    if let result = postProcess(bytes: _buffer) {
                        results.append(result)
                    }
                    _buffer.removeAll()
                    _isFrameBegin = false
                }
            }

            i += 1
        }

        return results
    }

    func postProcess(bytes: [UInt8]) -> (ResponseV2, FrameV2)? {
        var bytes = bytes
        V2.descape(&bytes)       // 逆转义
        V2.swapEndian(&bytes)  // 小端转大端
        guard bytes.count > 10 else { return nil }  // 确保达到最低长度

        let length = Int(bytes[2]) << 8 + Int(bytes[3])
        let type = Int(bytes[4]) << 8 + Int(bytes[5])
        let checksum = Int(bytes[bytes.count - 4]) << 8 + Int(bytes[bytes.count - 3])

        // 检查长度是否符合，否则丢弃
        guard length == bytes.count - 8 else { return nil }

        // 计算 checksum 是否正确
        var temp = 0
        for i in 2..<bytes.count - 4 {
            let value = bytes[i]
            temp += Int(value)
        }
        let checksumCorrect = ((1 << 16 - 1) - (temp % (1 << 16)) == checksum)

        switch type {
        case 0x1203:
            // 根据 type 再检查一次 length
            guard bytes.count == 514 + 10 else { return nil }
            let frame = FrameV2(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: Array(bytes[4..<6]),
                            payload: Array(bytes[6..<bytes.count - 4]),
                            checksum: Array(bytes[(bytes.count - 4)..<(bytes.count - 2)]),
                            end: Array(bytes[(bytes.count - 2)..<(bytes.count)]),
                            isChecksumCorrect: checksumCorrect)
            let response = ResponseV2.sampledData(Array(bytes[6..<8]), Array(bytes[8..<bytes.count - 4]))
            return (response, frame)

        case 0x1201:
            guard bytes.count == 64 + 10 else { return nil }
            let frame = FrameV2(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: Array(bytes[4..<6]),
                            payload: Array(bytes[6..<bytes.count - 4]),
                            checksum: Array(bytes[(bytes.count - 4)..<(bytes.count - 2)]),
                            end: Array(bytes[(bytes.count - 2)..<(bytes.count)]),
                            isChecksumCorrect: checksumCorrect)
            let response = ResponseV2.deviceInfo(Array(bytes[6..<bytes.count - 4]))
            return (response, frame)

        case 0x1206:
            guard bytes.count == 2 + 10 else { return nil }
            let frame = FrameV2(header: Array(bytes[0..<2]),
                                length: Array(bytes[2..<4]),
                                type: Array(bytes[4..<6]),
                                payload: Array(bytes[6..<bytes.count - 4]),
                                checksum: Array(bytes[(bytes.count - 4)..<(bytes.count - 2)]),
                                end: Array(bytes[(bytes.count - 2)..<(bytes.count)]),
                                isChecksumCorrect: checksumCorrect)
            let response = ResponseV2.firmwareVersion(Array(bytes[6..<bytes.count - 4]))
            return (response, frame)

        case 0x110F:
            guard bytes.count == 2 + 10 else { return nil }
            let frame = FrameV2(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: Array(bytes[4..<6]),
                            payload: Array(bytes[6..<bytes.count - 4]),
                            checksum: Array(bytes[(bytes.count - 4)..<(bytes.count - 2)]),
                            end: Array(bytes[(bytes.count - 2)..<(bytes.count)]),
                            isChecksumCorrect: checksumCorrect)
            let response = ResponseV2.ok
            return (response, frame)

        case 0x1104:
            guard bytes.count == 2 + 10 else { return nil }
            let frame = FrameV2(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: Array(bytes[4..<6]),
                            payload: Array(bytes[6..<bytes.count - 4]),
                            checksum: Array(bytes[(bytes.count - 4)..<(bytes.count - 2)]),
                            end: Array(bytes[(bytes.count - 2)..<(bytes.count)]),
                            isChecksumCorrect: checksumCorrect)
            let payload = Int(bytes[6]) << 8 + Int(bytes[7])
            if payload == 0x0001 {
                let response = ResponseV2.click(.single)
                return (response, frame)
            } else if payload == 0x0002 {
                let response = ResponseV2.click(.double)
                return (response, frame)
            } else if payload == 0x0003 {
                let response = ResponseV2.click(.up)
                return (response, frame)
            } else if payload == 0x0004 {
                let response = ResponseV2.click(.down)
                return (response, frame)
            } else {
                return nil
            }

        default:
            let frame = FrameV2(header: Array(bytes[0..<2]),
                            length: Array(bytes[2..<4]),
                            type: Array(bytes[4..<6]),
                            payload: Array(bytes[6..<bytes.count - 4]),
                            checksum: Array(bytes[(bytes.count - 4)..<(bytes.count - 2)]),
                            end: Array(bytes[(bytes.count - 2)..<(bytes.count)]),
                            isChecksumCorrect: checksumCorrect)
            let response = ResponseV2.unknown
            return (response, frame)
        }
    }
}

//
//  SessionV2.swift
//  Naptime
//
//  Created by PointerFLY on 02/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public protocol SessionV2Protocol {

    /// Send a instruction to the device.
    ///
    /// - Parameter instruction: V2 version Instruction
    func send(instruction: InstructionV2)
}


/// Session that is compatible with V2 Naptime device.
open class SessionV2: BaseSession, SessionV2Protocol {

    private let _processor = ProcessorV2()

    open func send(instruction: InstructionV2) {
        var bytes = instruction.bytes
        V2.swapEndian(&bytes)
        V2.escape(&bytes)
        send(bytes: bytes)
    }

    override func process(bytes: [UInt8]) {
        let results = _processor.process(bytes: bytes)

        for result in results {
            notifyResponse(withFrame: result.frame, response: result.response, object: self)
        }
    }
}

open class SimulatorSessionV2: SessionV2Protocol {

    public init() { }
    
    open func send(instruction: InstructionV2) {
        switch instruction {
        case .startSampling:
            _timer = DispatchSource.makeTimerSource(flags: [.strict], queue: DispatchQueue.main)
            let item = DispatchWorkItem(block: {
                var payload = [UInt8]()
                for _ in 0..<258 {
                    let value = arc4random() % (1 << 16)
                    payload.append(contentsOf:[UInt8(value/256), UInt8(value%256)])
                }
                let response = ResponseV2.sampledData(Array(payload[0..<2]), Array(payload[2..<payload.count]))
                let length: [UInt8] = [0x02, 0x04]
                let type: [UInt8] = [0x21, 0x03]
                let checksum = V2.caculateChecksum(length: length, type: type, payload: payload)
                let frame = FrameV2(header: FrameV2.kHeader, length: length, type: type, payload: payload, checksum: checksum, end: FrameV2.kEnd, isChecksumCorrect: true)
                notifyResponse(withFrame: frame, response: response, object: self)
            })
            _timer?.setEventHandler(handler: item)
            _timer?.scheduleRepeating(deadline: .now(), interval: 1.0)
            _timer?.resume()

        case .stopSampling:
            _timer?.cancel()
            _timer = nil

        case .requestDeviceInfo:
            let length: [UInt8] = [0x00, 0x42]
            let type: [UInt8] = [0x12, 0x01]
            let payload = [UInt8](repeating: UInt8(0), count: 64)
            let checksum = V2.caculateChecksum(length: length, type: type, payload: payload)
            let frame = FrameV2(header: FrameV2.kHeader, length: length, type: type, payload: payload, checksum: checksum, end: FrameV2.kEnd, isChecksumCorrect: true)
            let response = ResponseV2.deviceInfo(payload)
            notifyResponse(withFrame: frame, response: response, object: self)

        case .requestFirmwareVersion:
            let length: [UInt8] = [0x00, 0x04]
            let type: [UInt8] = [0x12, 0x06]
            let payload: [UInt8] = [0x20, 0x00]
            let checksum = V2.caculateChecksum(length: length, type: type, payload: payload)
            let frame = FrameV2(header: FrameV2.kHeader, length: length, type: type, payload: payload, checksum: checksum, end: FrameV2.kEnd, isChecksumCorrect: true)
            let response = ResponseV2.deviceInfo(payload)
            notifyResponse(withFrame: frame, response: response, object: self)

        case .updateDeviceInfo: ok()
        case .sendDeviceInfo(_): ok()
        case .updateFirmware: ok()
        case .sendFirmware(_): ok()
        case .custom(_): break
        }
    }

    private func ok() {
        let length: [UInt8] = [0x00, 0x04]
        let type: [UInt8] = [0x11, 0x0F]
        let payload: [UInt8] = []
        let checksum = V2.caculateChecksum(length: length, type: type, payload: payload)
        let frame = FrameV2(header: FrameV2.kHeader, length: length, type: type, payload: [], checksum: checksum, end: FrameV2.kEnd, isChecksumCorrect: true)
        let response = ResponseV2.ok
        notifyResponse(withFrame: frame, response: response, object: self)
    }

    private var _timer: DispatchSourceTimer?
}

private func notifyResponse(withFrame frame: FrameV2, response: ResponseV2, object: SessionV2Protocol) {
    #if OPEN_PRODUCT
        let info: [String: Any] = [kSessionResponseKey: response]
        NotificationCenter.default.post(name: kSessionDidResponseNotificationName, object: object, userInfo: info)
    #else
        let info: [String: Any] = [kSessionResponseKey: response,
                                   kSessionFrameKey: frame]
        NotificationCenter.default.post(name: kSessionDidResponseNotificationName, object: object, userInfo: info)
    #endif
}

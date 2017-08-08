//
//  SessionV1.swift
//  Naptime
//
//  Created by PointerFLY on 02/05/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public protocol SessionV1Protocol {
    func send(instruction: InstructionV1)
}

open class SessionV1: BaseSession, SessionV1Protocol {

    private let _processor = ProcessorV1()

    open func send(instruction: InstructionV1) {
        send(bytes: instruction.bytes)
    }

    override func process(bytes: [UInt8]) {
        let result = _processor.process(bytes: bytes)

        if let (response, frame) = result {
            let info: [String : Any] = [kSessionResponseKey: response,
                                        kSessionFrameKey: frame]
            NotificationCenter.default.post(name: kSessionDidResponseNotificationName, object: self, userInfo: info)
        }
    }
}

open class SimulatorSessionV1: SessionV1Protocol {

    public init() { }

    open func send(instruction: InstructionV1) {
        switch instruction {
        case .wakeup:
            let response = ResponseV1.wakenUp
            let frame = FrameV1(header: FrameV1.kHeader, length: [0x00, 0x01], type: 0xFC, sequence: [], payload: [], checksum: 0x03, isChecksumCorrect: true)
            let info: [String: Any] = [kSessionResponseKey: response,
                                       kSessionFrameKey: frame]
            NotificationCenter.default.post(name: kSessionDidResponseNotificationName, object: self, userInfo: info)

        case .requestDeviceID:
            let id = [UInt8](repeating: 0x00, count: 10)
            let response = ResponseV1.deviceID(id)
            let frame = FrameV1(header: FrameV1.kHeader, length: [0x00, 0x10], type: 0xFA, sequence: [0x00, 0x00, 0x00], payload: id, checksum: 0xFC, isChecksumCorrect: true)
            let info: [String: Any] = [kSessionResponseKey: response,
                                       kSessionFrameKey: frame]
            NotificationCenter.default.post(name: kSessionDidResponseNotificationName, object: self, userInfo: info)

        case .startTransmission:
            _timer = DispatchSource.makeTimerSource(flags: [.strict], queue: DispatchQueue.main)
            let item = DispatchWorkItem(block: {
                var payload = [UInt8]()
                for _ in 0..<256 {
                    let value = arc4random() % 1024
                    payload.append(contentsOf:[UInt8(value/256), UInt8(value%256)])
                }
                let response = ResponseV1.brainWave(0, payload)
                let frame = FrameV1(header: FrameV1.kHeader, length: [0x02, 0x04], type: 0xFA, sequence: [0x00, 0x00, 0x00], payload: payload, checksum: 0xFF, isChecksumCorrect: true)
                let info: [String: Any] = [kSessionResponseKey: response,
                                           kSessionFrameKey: frame]
                NotificationCenter.default.post(name: kSessionDidResponseNotificationName, object: self, userInfo: info)
            })
            _timer?.setEventHandler(handler: item)
            _timer?.scheduleRepeating(deadline: .now(), interval: 1.0)
            _timer?.resume()

        case .stopTransmission:
            _timer?.cancel()
            _timer = nil

        case .custom(_): break
        }
    }

    private var _timer: DispatchSourceTimer?
}

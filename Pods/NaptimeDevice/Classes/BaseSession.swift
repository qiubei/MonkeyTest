//
//  BaseSession.swift
//  NaptimeDevice
//
//  Created by PointerFLY on 17/01/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import ExternalAccessory

#if !OPEN_PRODUCT
    /// Notification userInfo key to get frame.
    public let kSessionFrameKey = "kSessionFrameKey"
#endif
/// Notification userInfo key to get response.
public let kSessionResponseKey = "kSessionResponseKey"
/// Notify when device send message back.
public let kSessionDidResponseNotificationName = Notification.Name("kSessionDidResponseNotificationName")

open class BaseSession: EASession, StreamDelegate {

    /// Init a BaseSession with a accessory and specific protocol.
    /// Result is undefined if the protocol does not match with the accessory.
    ///
    /// - Parameters:
    ///   - accessory: EAAcessory
    ///   - protocolString: protocol
    public override init(accessory: EAAccessory, forProtocol protocolString: String) {
        #if swift(>=3.2)
            super.init(accessory: accessory, forProtocol: protocolString)!
        #else
            super.init(accessory: accessory, forProtocol: protocolString)
        #endif

        self.inputStream?.delegate = self
        self.inputStream?.schedule(in: RunLoop.current, forMode: .commonModes)
        self.inputStream?.open()

        self.outputStream?.delegate = self
        self.outputStream?.schedule(in: RunLoop.current, forMode: .commonModes)
        self.outputStream?.open()

        EAAccessoryManager.shared().registerForLocalNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisconnected(_:)), name: Notification.Name.EAAccessoryDidDisconnect, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func handleDisconnected(_ notification: Notification) {
        let accessory = notification.userInfo![EAAccessoryKey] as! EAAccessory
        if accessory == self.accessory {
            self.outputStream?.close()
            self.inputStream?.close()
        }
    }

    func send(bytes: [UInt8]) {
        _outputQueue.append(contentsOf: bytes)
        sendBytes()
    }

    func process(bytes: [UInt8]) {
        fatalError("process(bytes:) is not implemented!")
    }

    private var _outputQueue = [UInt8]()

    private func sendBytes() {
        while self.outputStream!.hasSpaceAvailable
            && _outputQueue.count > 0
        {
            let bytesSent = self.outputStream!.write(_outputQueue, maxLength: _outputQueue.count)

            if bytesSent > 0 {
                Log.debug("bytesSent: \(bytesSent) bytes")
                _outputQueue.removeSubrange(0..<bytesSent)
            } else if (bytesSent == -1) {
                break
            }
        }
    }

    private func receiveBytes() {
        while self.inputStream!.hasBytesAvailable {
            var buffer = Array<UInt8>(repeating: 0, count: 256)
            let bytesRead = self.inputStream!.read(&buffer, maxLength: buffer.count)

            if bytesRead > 0 {
                Log.debug("bytesRead: \(bytesRead) bytes")
                buffer.removeSubrange(bytesRead..<buffer.count)
                process(bytes: buffer)
            } else {
                break
            }
        }
    }

    // MARK: - StreamDelegate

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        let streamName = (aStream == self.inputStream) ? "input stream" : "output stream"

        switch eventCode {
        case Stream.Event.openCompleted:
            Log.info(streamName + " open complete")

        case Stream.Event.endEncountered:
            Log.info(streamName + " end encountered")

        case Stream.Event.errorOccurred:
            Log.error(streamName + " error occurred")
            
        case Stream.Event.hasBytesAvailable:
            receiveBytes()

        case Stream.Event.hasSpaceAvailable:
            sendBytes()

        default:
            Log.warn("multiple stream event: " + String(describing: eventCode))
        }
    }
}

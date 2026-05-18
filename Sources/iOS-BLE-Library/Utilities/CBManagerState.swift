//
//  CBManagerState.swift
//
//
//  Created by Dinesh Harjani on 23/8/22.
//

#if MOCK_TRANSPORT
import CoreBluetoothMock
#else
import CoreBluetooth
#endif
import Foundation

// MARK: - CBManagerState
#if hasFeature(RetroactiveAttribute)
@available(iOS 10.0, *)
@available(macOS 10.13, *)
extension CBManagerState: @retroactive CustomDebugStringConvertible, @retroactive CustomStringConvertible {

	public var debugDescription: String {
		return description
	}

	public var description: String {
		switch self {
		case .poweredOff:
			return "poweredOff"
		case .poweredOn:
			return "poweredOn"
		case .resetting:
			return "resetting"
		case .unauthorized:
			return "unauthorized"
		case .unsupported:
			return "unsupported"
        default:
            return "unknown"
		}
	}
}
#endif

//
//  KeyChainUtil.swift
//  P&D_App
//
//  Created by Azuma on 2018/11/06.
//  Copyright © 2018 P&D. All rights reserved.
//

import Foundation
import KeychainAccess

class KeyChainUtil: NSObject {

    static let shared = KeyChainUtil()

    private(set) var keyChain = Keychain(service: Bundle.main.bundleIdentifier!)

    private override init() {}

    public func set(key: String, value: String) {
        keyChain[key] = value
    }

    public func get(key: String) -> String? {
        do {
            return try keyChain.get(key)
        } catch {
            return nil
        }
    }

    public func remove(key: String) {
        do {
            try keyChain.remove(key)
        } catch {
            print(error.localizedDescription)
        }
    }
}

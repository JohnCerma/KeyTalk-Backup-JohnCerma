//
//  KeychainKey.swift
//  KeyTalk client
//
//  Created by Rinshi Rastogi
//  Copyright © 2018 KeyTalk. All rights reserved.
//

import Foundation


struct KeychainKey
{
	fileprivate let _key: SecKey
	
	init(key: SecKey)
	{
		_key = key;
	}
	
	var ItemRef: SecKeychainItem
	{
		get { return unsafeBitCast(_key, to: SecKeychainItem.self) }
	}
}

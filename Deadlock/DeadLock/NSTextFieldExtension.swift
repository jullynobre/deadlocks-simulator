//
//  NSTextFieldExtension.swift
//  DeadLock
//
//  Created by Jully Nobre on 03/06/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

extension NSTextField {
	func activate(strValue: String) {
		self.stringValue = strValue
		self.textColor = NSColor(calibratedWhite: 1.0, alpha: 1.0)
	}
	
	func deactivate() {
		self.stringValue = "--"
		self.textColor = NSColor(calibratedWhite: 0.5, alpha: 0.5)
	}
}

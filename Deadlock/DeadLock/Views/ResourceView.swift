//
//  ResourceView.swift
//  DeadLock
//
//  Created by Jully Nobre on 26/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

class ResourceView: NSView {
	
	var idLabel: NSTextView = NSTextView(frame: NSRect(x: 4, y: 4, width: 18, height: 12))
	var nameLabel: NSTextView = NSTextView()
	var quantityLabel: NSTextView = NSTextView()
	var availableLabel: NSTextView = NSTextView()
	var resourceImage: NSImageView = NSImageView()
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
        self.layer?.backgroundColor = .init(red: 58/255, green: 58/255, blue: 58/255, alpha: 0.7)
		self.layer?.cornerRadius = 5
    }
}

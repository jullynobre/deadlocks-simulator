//
//  ResourceView.swift
//  DeadLock
//
//  Created by Jully Nobre on 26/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

class ResourceView: NSView {
	
	var idLabel: NSTextView = NSTextView(frame: NSRect(x: 4, y: 40, width: 23, height: 12))
	var nameLabel: NSTextView = NSTextView(frame: NSRect(x: 34, y: 32, width: 65, height: 12))
	var quantityLabel: NSTextView = NSTextView(frame: NSRect(x: 34, y: 14, width: 30, height: 12))
	var availableLabel: NSTextView = NSTextView(frame: NSRect(x: 66, y: 12, width: 30, height: 12))
	var resourceImage: NSImageView = NSImageView(frame: NSRect(x: 8, y: 12, width: 25, height: 25))
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
        self.layer?.backgroundColor = .init(red: 58/255, green: 58/255, blue: 58/255, alpha: 0.7)
		self.layer?.cornerRadius = 5
		
		self.idLabel.font = NSFont(name: "Helvetica", size: 11)
		self.idLabel.backgroundColor = .clear
		self.idLabel.textColor = .init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
		self.idLabel.isEditable = false
		self.addSubview(idLabel)
		
		self.resourceImage.image = NSImage(named: NSImage.Name("resourceImage"))
		
		self.nameLabel.font = NSFont(name: "Helvetica", size: 10)
		self.nameLabel.backgroundColor = .clear
		self.nameLabel.isEditable = false
		self.addSubview(nameLabel)
		
		self.quantityLabel.backgroundColor = .clear
		self.quantityLabel.isEditable = false
		self.addSubview(quantityLabel)
		
		self.availableLabel.backgroundColor = .clear
		self.availableLabel.textColor = .init(red: 192/255, green: 328/255, blue: 127/255, alpha: 1.0)
		self.addSubview(availableLabel)
		
    }
	
	func activateResource(id: Int, quantity: Int, available: Int, name: String) {
		self.idLabel.string = "\(id)"
		self.nameLabel.string = "\(name)"
		self.quantityLabel.string = "\(quantity)"
		self.availableLabel.string = "\(available)"
		
		self.addSubview(resourceImage)
		self.layer?.backgroundColor = .init(red: 84/255, green: 84/255, blue: 84/255, alpha: 0.7)
	}
	
	func updateAvailableLabel(newValue: String) {
		self.availableLabel.string = "\(newValue)"
	}
}

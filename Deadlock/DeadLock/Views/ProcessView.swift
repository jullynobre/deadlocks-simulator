//
//  ProcessesView.swift
//  DeadLock
//
//  Created by Jully Nobre on 26/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

class ProcessView: NSView {

	private var idLabel: NSTextView = NSTextView(frame: NSRect(x: 4, y: 60, width: 23, height: 12))
	private var loadImage: NSImageView = NSImageView(frame: NSRect(x: 8, y: 27, width: 25, height: 25))
	private var tsLabel: NSTextView = NSTextView(frame: NSRect(x: 36, y: 37, width: 60, height: 17))
	private var tuLabel: NSTextView = NSTextView(frame: NSRect(x: 36, y: 16, width: 60, height: 17))
    
    public var process: Process?
	
	private let gesture = NSClickGestureRecognizer(target: self, action: Selector(("didClick")))
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		self.layer?.cornerRadius = 5
		
		self.idLabel.backgroundColor = .clear
		self.idLabel.font = NSFont(name: "Helvetica", size: 11)
		self.idLabel.textColor = .init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
		self.idLabel.isEditable = false
		self.addSubview(idLabel)
		
		self.tsLabel.isEditable = false
		self.tsLabel.backgroundColor = .clear
		self.addSubview(tsLabel)
		
		self.tuLabel.isEditable = false
		self.tuLabel.backgroundColor = .clear
		self.addSubview(tuLabel)
		
		self.addSubview(loadImage)
		
		self.setHiddenAtributes(isHidden: true)
		
		self.loadImage.image = NSImage(named: NSImage.Name("processImage"))
		
    }
	
	func activateProcess(id: Int, ts: Int, tu: Int) {
		self.idLabel.string = "\(id)"
		self.tsLabel.string = "Ts = \(ts)"
		self.tuLabel.string = "Tu = \(tu)"
		
		self.addGestureRecognizer(self.gesture)
		
		self.setHiddenAtributes(isHidden: false)
	}
	
	func deactivateProcess() {
		self.setHiddenAtributes(isHidden: true)
		self.removeGestureRecognizer(self.gesture)
	}
	
	@objc
	func didClick() {
		let confirmKill = NSAlert()
		confirmKill.messageText = "Matar processo \(self.idLabel.string)"
		confirmKill.informativeText = "Você deseja realmente matar esse processo? Esta é uma ação irreversível."
		confirmKill.addButton(withTitle: "Cancel")
		confirmKill.addButton(withTitle: "Matar")
		confirmKill.alertStyle = .critical
		
		
		switch confirmKill.runModal() {
		case NSApplication.ModalResponse.alertFirstButtonReturn:
			print("Did Tap Cancel")
		case NSApplication.ModalResponse.alertSecondButtonReturn:
			print("Did Tap Kill")
            self.process?.cancel()
		default:
			print("Unavailable option")
		}
	}
	
	func runImageAnimation() {
		//Start gif
	}
	
	func stopImageAnimation() {
		//Stop gif
	}
	
	func setHiddenAtributes(isHidden: Bool) {
		self.idLabel.isHidden = isHidden
		self.loadImage.isHidden = isHidden
		self.tsLabel.isHidden = isHidden
		self.tuLabel.isHidden = isHidden
		
		let activatedColor = CGColor.init(red: 84/255, green: 84/255, blue: 84/255, alpha: 0.7)
		let hiddenColor = CGColor.init(red: 58/255, green: 58/255, blue: 58/255, alpha: 0.7)
		self.layer?.backgroundColor = isHidden ? hiddenColor : activatedColor
	}
}

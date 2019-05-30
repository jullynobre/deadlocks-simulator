//
//  AddProcessViewController.swift
//  DeadLock
//
//  Created by Jully Nobre on 30/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

protocol ProcessAdded: class {
	func didAddedProcess(_ sender: AddProcessViewController,
						 processId: Int,
						 processTs: Int,
						 processTu: Int)
}

class AddProcessViewController: NSViewController {

	@IBOutlet weak var processIdTextField: NSTextField!
	@IBOutlet weak var processTuTextField: NSTextField!
	@IBOutlet weak var processTsTextField: NSTextField!
	
	weak var delegate: ProcessAdded?
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	@IBAction func didTapSaveButton(_ sender: Any) {
		delegate?.didAddedProcess(self, processId: Int(self.processIdTextField!.stringValue) ?? 0,
								  processTs: Int(self.processTsTextField!.stringValue) ?? 0,
								  processTu: Int(self.processTuTextField!.stringValue) ?? 0)
		self.dismiss(nil)
	}
	
	@IBAction func didTapCancelButton(_ sender: Any) {
		self.dismiss(nil)
	}
}

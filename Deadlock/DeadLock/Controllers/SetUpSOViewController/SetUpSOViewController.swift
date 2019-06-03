//
//  SetUpSOViewController.swift
//  DeadLock
//
//  Created by Jully Nobre on 03/06/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

protocol SetUpSODelegate: class {
	func didSetUpSO(_ sender: SetUpSOViewController, refreshTime: Int)
}

class SetUpSOViewController: NSViewController {
	@IBOutlet weak var refreshTimeTextField: NSTextField!
	
	weak var delegate: SetUpSODelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	@IBAction func didTapSaveButton(_ sender: Any) {
		if let refreshTime = Int(self.refreshTimeTextField.stringValue) {
			self.delegate?.didSetUpSO(self, refreshTime: refreshTime)
			self.dismiss(nil)
		}
	}
	
}

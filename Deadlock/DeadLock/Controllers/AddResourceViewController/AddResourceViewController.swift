//
//  AddResourceViewController.swift
//  DeadLock
//
//  Created by Jully Nobre on 30/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

protocol ResourceAdded: class {
	func didAddedResource(_ sender: AddResourceViewController,
						 resourceId: Int,
						 resourceName: String,
						 resourceQttyInstances: Int)
}

class AddResourceViewController: NSViewController {

	@IBOutlet weak var resourceIdTextField: NSTextField!
	@IBOutlet weak var resourceNameTextField: NSTextField!
	@IBOutlet weak var resourcesQttyTextField: NSTextField!
	
	weak var delegate: ResourceAdded?
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
	@IBAction func didTapCancelButton(_ sender: Any) {
		self.dismiss(nil)
	}
	
	@IBAction func didTapSaveButton(_ sender: Any) {
		self.delegate?.didAddedResource(self, resourceId: Int(self.resourceIdTextField.stringValue) ?? 0,
										resourceName: self.resourceNameTextField.stringValue,
										resourceQttyInstances: Int(self.resourcesQttyTextField.stringValue) ?? 0)
		self.dismiss(nil)
	}
}

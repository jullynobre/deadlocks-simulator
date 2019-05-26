//
//  ViewController.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 08/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	var matrixLabels: [[NSTextField]] = [[]]
	var processesIdLabels: [NSTextField] = []
	var resourcesIdLabels: [NSTextField] = []
	var processesArrayLabels: [NSTextField] = []
	
	@IBOutlet weak var processesView: NSView!
	@IBOutlet weak var resourcesView: NSView!
	@IBOutlet weak var consoleScrollView: NSScrollView!
	@IBOutlet weak var consoleBgView: NSView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.generateMatrixLabels()
		self.generateResourcesLabels()
		self.generateProcessesLabels()
		self.generateProcessesArrayLabels()
		self.configureBordersAndColors()
	}
	
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension SO {
    func killProcessWithMoreResources () {
        var targetedProcess = processes.values.first!
        
        for p in processes.values {
            if (p.resoucersHistory.count > targetedProcess.resoucersHistory.count) {
                targetedProcess = p
            }
        }
        
        print("killing process \(targetedProcess.id)")
        killProcess(id: targetedProcess.id)
    }
}

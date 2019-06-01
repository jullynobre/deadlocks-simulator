//
//  ViewController.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 08/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet weak var processesView: NSView!
	@IBOutlet weak var resourcesView: NSView!
	@IBOutlet weak var consoleScrollView: NSScrollView!
	@IBOutlet weak var consoleBgView: NSView!
	
	var matrixLabels: [[NSTextField]] = [[]]
	var processesIdLabels: [NSTextField] = []
	var resourcesIdLabels: [NSTextField] = []
	var processesArrayLabels: [NSTextField] = []
	
	var processesViews: [NSView] = []
	var resourcesViews: [NSView] = []

	var so: SO?
    
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        self.so = SO(resourcesTable: [:], processes: [:], viewController: self)
		
		setupInterface()
	}
	
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
	}
	
	@IBAction func didTapNewProcessButton(_ sender: Any) {
		//if self.processesViews.count < 15 {
		let addProcessVC = AddProcessViewController()
		addProcessVC.delegate = self
		self.presentAsSheet(addProcessVC)
		//}
	}
	
	@IBAction func didTapNewResourceButton(_ sender: Any) {
		//if self.resourcesViews.count < 10 {
		let addResourceVC = AddResourceViewController()
		addResourceVC.delegate = self
		self.presentAsSheet(addResourceVC)
		//
	}
}

extension ViewController: AddProcessDelegate, AddResourceDelegate {
	func didAddedProcess(_ sender: AddProcessViewController, processId: Int, processTs: Int, processTu: Int) {
        let newProcess = Process(id: processId, ts: Double(processTs), tu: Double(processTu), resourcesTable: so!.resourcesTable, viewController: self)
        so!.addProcess(processId: processId, process: newProcess)
	}
	
	func didAddedResource(_ sender: AddResourceViewController, resourceId: Int, resourceName: String, resourceQttyInstances: Int) {
        let newResouce = Resource(name: resourceName, quantity: resourceQttyInstances)
        so!.addResouce(resouceId: resourceId, resouce: newResouce)
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

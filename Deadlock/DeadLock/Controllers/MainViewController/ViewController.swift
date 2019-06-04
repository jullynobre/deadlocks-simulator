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
	
	var acquiredResoucesLabels: [[NSTextField]] = [[]]
	var resourcesIdLabels: [NSTextField] = []
	var processesIdLabels: [NSTextField] = []
	var wantedResourcesLabels: [NSTextField] = []
	
	var processesViews: [ProcessView] = []
	var resourcesViews: [ResourceView] = []

	var so: SO?
    
	
	override func viewDidLoad() {
     super.viewDidLoad()
		
	   setupInterface()
	}
	
	override func viewDidAppear() {
		let setUpSOVC = SetUpSOViewController()
		setUpSOVC.delegate = self
		self.presentAsSheet(setUpSOVC)
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

extension ViewController: AddProcessDelegate, AddResourceDelegate, SetUpSODelegate {
	func didSetUpSO(_ sender: SetUpSOViewController, refreshTime: Int) {
		self.so = SO(resourcesTable: [:], processes: [:], view: self)
		self.so?.watchProcesses(refreshTime: UInt32(refreshTime))
		print("RefreshTime \(refreshTime)")
	}
	
	func didAddedProcess(_ sender: AddProcessViewController, processId: Int, processTs: Int, processTu: Int) {
        let newProcess = Process(id: processId, ts: Double(processTs), tu: Double(processTu), resourcesTable: so!.resourcesTable, view: self)
        so!.addProcess(processId: processId, process: newProcess)
        processesViews[processId].process = so?.processes[processId]
	}
	
	func didAddedResource(_ sender: AddResourceViewController, resourceId: Int, resourceName: String, resourceQttyInstances: Int) {
        let resouceView = resourcesViews[resourceId]
        let newResouce = Resource(name: resourceName, quantity: resourceQttyInstances, view: resouceView)
        so!.addResouce(resouceId: resourceId, resouce: newResouce)
        
        resouceView.activateResource(id: resourceId, quantity: resourceQttyInstances, available: resourceQttyInstances, name: resourceName)
	}
}

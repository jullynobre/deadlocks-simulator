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
	var availableResourcesLabels: [NSTextField] = []
	
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
        self.so = SO(resourcesTable: [:], processes: [:])
        self.so?.watchProcesses(refreshTime: UInt32(refreshTime))
        so?.displayLog = { (deadlockMessenge: String) in
            DispatchQueue.main.sync {
                self.consoleScrollView.documentView?.insertText("\nSO: \(deadlockMessenge)\n\n")
            }
        }
	}
	
	func didAddedProcess(_ sender: AddProcessViewController, processId: Int, processTs: Int, processTu: Int) {
        let newProcess = Process(id: processId, ts: Double(processTs), tu: Double(processTu), resources: so!.resources)
        so!.registerProcess(process: newProcess)
        
        processesViews[processId].killProcess = {
            self.so?.killProcess(id: processId)
            self.processesViews[processId].deactivateProcess()
        }
        
        newProcess.displayLog = { (m: String) in
            DispatchQueue.main.async {
                self.consoleScrollView.documentView?.insertText("\(getTime()) - \(processId): \(m)\n")
            }
        }
        newProcess.displayEndProcess = {
            DispatchQueue.main.sync {
                self.processesIdLabels[processId].deactivate()
                for rk in (self.so?.resources.keys)! {
                    self.acquiredResoucesLabels[rk][processId].deactivate()
                }
            }
        }
        newProcess.displayStartProcess = {
            DispatchQueue.main.async {
                self.processesViews[processId].activateProcess(id: processId, ts: processTs, tu: processTu)
                self.processesIdLabels[processId].activate(processId)
                for rk in (self.so?.resources.keys)! {
                    self.acquiredResoucesLabels[rk][processId].activate(0)
                }
            }
        }
        newProcess.displayWantedResource = { (resource: Int?) in
            DispatchQueue.main.async {
                if let r = resource {
                    self.wantedResourcesLabels[processId].activate(r)
                } else {
                    self.wantedResourcesLabels[processId].deactivate()
                }
            }
        }
        newProcess.displayAllocatedResouceCount = {(resourceId: Int, resourceQuantity: Int) in
            DispatchQueue.main.async {
//                self.resourcesViews[resourceId].updateAvailableLabel(newValue: String(resourceQuantity))
                self.acquiredResoucesLabels[resourceId][processId].activate(resourceQuantity)
            }
        }
	}
	
    func didAddedResource(_ sender: AddResourceViewController, resourceId: Int, resourceName: String, resourceQttyInstances: Int) {
        let resouceView = resourcesViews[resourceId]
        let newResouce = Resource(name: resourceName, quantity: resourceQttyInstances)
        so!.registerResouce(resouceId: resourceId, resouce: newResouce)
        
        resouceView.activateResource(id: resourceId, quantity: resourceQttyInstances, available: resourceQttyInstances, name: resourceName)
        resourcesIdLabels[resourceId].activate(resourceId)
        availableResourcesLabels[resourceId].activate(resourceQttyInstances)
        
        newResouce.displayAvalibleReasources = { (quantity: Int) in
            DispatchQueue.main.async {
                self.availableResourcesLabels[resourceId].activate(quantity)
            }
        }
	}
}

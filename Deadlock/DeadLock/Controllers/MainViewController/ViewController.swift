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
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        let resouces = [1: Resource(name: "Impressora", quantity: 3), 2: Resource(name: "Plotter", quantity: 2)]
        let processes = [1: Process(id: 1, ts: 2.0, tu: 5.0, resourcesTable: resouces, viewController: self),
                         2: Process(id: 2, ts: 2.0, tu: 5.0, resourcesTable: resouces, viewController: self)]
        
        let so = SO(resourcesTable: resouces, processes: processes, viewController: self)
        
        so.watchProcesses(refreshTime: 3)
        
        for p in processes {
            p.value.start()
        }
		
		setupInterface()
	}
	
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
	}
	
	@IBAction func didTapNewProcessButton(_ sender: Any) {
		self.presentAsSheet(AddProcessViewController())
	}
	
	@IBAction func didTapNewResourceButton(_ sender: Any) {
		self.presentAsSheet(AddResourceViewController())
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

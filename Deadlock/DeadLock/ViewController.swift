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
		
		self.processesView.wantsLayer = true
		self.processesView.layer?.backgroundColor = .init(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
		self.processesView.layer?.borderColor = .white
		self.processesView.layer?.borderWidth = 0.2
		self.processesView.layer?.cornerRadius = 5
		
		self.resourcesView.wantsLayer = true
		self.resourcesView.layer?.backgroundColor = .init(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.7)
		self.resourcesView.layer?.borderColor = .white
		self.resourcesView.layer?.borderWidth = 0.2
		self.resourcesView.layer?.cornerRadius = 5
		
		self.consoleBgView.wantsLayer = true
		self.consoleBgView.layer?.backgroundColor = .init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
	}
	
	func generateMatrixLabels() {
		let heigth = 17, width = 21, xOrigin = 757, yOrigin = 607, xIncrease = 25, yIncrease = -25
		
		for xIndex in 0..<15 {
			self.matrixLabels.append([])
			for yIndex in 0..<10 {
				let xPosition = xOrigin + xIncrease * xIndex
				let yPosition = yOrigin + yIncrease * yIndex
				
				let label = self.createLabel(x: xPosition, y: yPosition, width: width, heigth: heigth)
				self.matrixLabels[xIndex].append(label)
			}
		}
	}
	
	func generateResourcesLabels() {
		let heigth = 17, width = 21, xPosition = 720, yOrigin = 607, yIncrease = -25
		
		for labelIndex in 0..<10 {
			let yPosition = yOrigin + yIncrease * labelIndex
			self.processesIdLabels.append(self.createLabel(x: xPosition, y: yPosition, width: width, heigth: heigth))
		}
	}
	
	func generateProcessesLabels() {
		let height = 17, width = 21, xOrigin = 757, yPosition = 644, xIncrease = 25
		
		for labelIndex in 0..<15 {
			let xPosition = xOrigin + xIncrease * labelIndex
			self.resourcesIdLabels.append(self.createLabel(x: xPosition, y: yPosition, width: width, heigth: height))
		}
	}
	
	func generateProcessesArrayLabels() {
		let height = 17, width = 21, xOrigin = 757, yPosition = 326, xIncrease = 25
		
		for labelIndex in 0..<15 {
			let xPosition = xOrigin + xIncrease * labelIndex
			self.processesArrayLabels.append(self.createLabel(x: xPosition, y: yPosition, width: width, heigth: height))
		}
	}
	
	func createLabel(x: Int, y: Int, width: Int, heigth: Int) -> NSTextField {
		let label = NSTextField()
		label.frame = CGRect(x: x, y: y, width: width, height: heigth)
		label.stringValue = "99"
		label.isBezeled = false
		label.isEditable = false
		label.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.0)
		self.view.addSubview(label)
		
		return label
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

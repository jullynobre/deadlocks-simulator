//
//  ViewControillerInterface.swift
//  DeadLock
//
//  Created by Jully Nobre on 26/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

extension ViewController {
	
	func setupInterface() {
		self.generateMatrixLabels()
		self.generateResourcesLabels()
		self.generateProcessesLabels()
		self.generateProcessesArrayLabels()
		self.configureBordersAndColors()
		
		self.generateProcessesViews()
		self.generateResourcesViews()
	}
	
	func configureBordersAndColors() {
		
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
			self.acquiredResoucesLabels.append([])
			for yIndex in 0..<10 {
				let xPosition = xOrigin + xIncrease * xIndex
				let yPosition = yOrigin + yIncrease * yIndex
				
				let label = self.createLabel(x: xPosition, y: yPosition, width: width, heigth: heigth)
				self.acquiredResoucesLabels[xIndex].append(label)
			}
		}
	}
	
	func generateResourcesLabels() {
		let height = 17, width = 21, xOrigin = 757, yPosition = 644, xIncrease = 25

		for labelIndex in 0..<10 {
			let xPosition = xOrigin + xIncrease * labelIndex
			self.resourcesIdLabels.append(self.createLabel(x: xPosition, y: yPosition, width: width, heigth: height))
		}
	}
	
	func generateProcessesLabels() {
		let heigth = 17, width = 21, xPosition = 720, yOrigin = 607, yIncrease = -25

		for labelIndex in 0..<15 {
			let yPosition = yOrigin + yIncrease * labelIndex
			self.processesIdLabels.append(self.createLabel(x: xPosition, y: yPosition, width: width, heigth: heigth))
		}
	}
	
	func generateProcessesArrayLabels() {
		let heigth = 17, width = 21, xPosition = 1020, yOrigin = 607, yIncrease = -25
		
		for labelIndex in 0..<15 {
			let yPosition = yOrigin + yIncrease * labelIndex
			self.wantedResourcesLabels.append(self.createLabel(x: xPosition, y: yPosition, width: width, heigth: heigth))
		}
	}
	
	func createLabel(x: Int, y: Int, width: Int, heigth: Int) -> NSTextField {
		let label = NSTextField()
		label.frame = CGRect(x: x, y: y, width: width, height: heigth)
		label.isBezeled = false
		label.isEditable = false
		label.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.0)
		label.deactivate()
		self.view.addSubview(label)
		
		return label
	}
	
	func generateResourcesViews() {
		let xOrigin = 20, yOrigin = 96, width = 106, height = 60
		
		for xIndex in 0..<5 {
			for yIndex in 0..<2 {
				let xPosition = xOrigin + 122 * xIndex
				let yPosition = yOrigin - 76 * yIndex
				
				let resource = ResourceView(frame: NSRect(x: xPosition, y: yPosition, width: width, height: height))
				self.resourcesView.addSubview(resource)
				self.resourcesViews.append(resource)
			}
		}
		
	}
	
	func generateProcessesViews() {
		let xOrigin = 20, yOrigin = 212, width = 106, height = 80
		
		for xIndex in 0..<5 {
			for yIndex in 0..<3 {
				let xPosition = xOrigin + 122 * xIndex
				let yPosition = yOrigin - 96 * yIndex
				
				let process = ProcessView(frame: NSRect(x: xPosition, y: yPosition, width: width, height: height))
				self.processesView.addSubview(process)
				self.processesViews.append(process)
			}
		}
	}
}

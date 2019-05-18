//
//  ViewController.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 08/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let resourcesTable: [Int: Resource] = [
            1: Resource(name: "Impressora", quantity: 2),
//            2: Resource(name: "Gravadora de DVD", quantity: 2),
//            3: Resource(name: "Câmera", quantity: 2),
            4: Resource(name: "Plotter", quantity: 2)]
        
        var processes: [Int: Process] = [
            1: Process(id: 1, ts: 1, tu: 5, resourcesTable: resourcesTable),
            2: Process(id: 2, ts: 1, tu: 3, resourcesTable: resourcesTable),
            3: Process(id: 3, ts: 1, tu: 2, resourcesTable: resourcesTable)
        ]
        
        let so = SO(resourcesTable: resourcesTable, processes: processes)
        
        for p in processes.values { p.start() }
        
        so.onDeadLock = { (so: SO) in
            print("DeadLock!!!")
            so.killProcessWithMoreResources()
        }
        
        so.watchProcesses(refreshTime: 1)
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

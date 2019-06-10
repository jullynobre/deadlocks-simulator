//
//  SO.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 10/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Foundation


class SO {
    
    var processes: [Int: Process]
    var killedProcesses: [Int] = []
    var resources: [Int: Resource]
    var isWatching = false
    
    init(resourcesTable: [Int: Resource], processes: [Int: Process]) {
        self.processes = processes
        self.resources = resourcesTable
    }
    
    func alocationMatrix() -> [Int: [Int: Int]] {
        var alocationMatrix = [Int: [Int:Int]]()
        for p in processes.keys.sorted(by: <) {
            alocationMatrix[p] = processes[p]!.allocatedResourcesCount
        }
        return alocationMatrix
    }
    
    func killProcess(id: Int) {
        let process = processes[id]!
        process.cancel()
        
        if let desiredResouceId = process.disiredResource {
            let desiredResouce = resources[desiredResouceId]!
            desiredResouce.cancelGiveTo(processId: id)
        }
        processes[id] = nil
    }
    
    func searchDeadLock() -> [Int] {
        var virtualyAvalibleResouces = resources.compactMap{$0.value.quantity > 0 ? $0.key : nil}
        var testProcessesIds: [Int?] = Array(processes.keys)
        
        var loop = true
        while loop {
            loop = false
            for id in testProcessesIds.compactMap({$0}) {
                if let p = processes[id] {
                    if virtualyAvalibleResouces.contains(p.disiredResource ?? -99) || p.disiredResource == nil {
                        loop = true
                        let allocatedReasources = self.resources.keys.filter {p.allocatedResourcesCount[$0] ?? 0 > 0}
                        virtualyAvalibleResouces.append(contentsOf: allocatedReasources)
                        let idIndex = testProcessesIds.firstIndex(of: id)!
                        testProcessesIds[idIndex] = nil
                    }
                }
            }
        }
        print(Array(Set(testProcessesIds.compactMap {$0})))
        return Array(Set(testProcessesIds.compactMap {$0}))
    }

    
    func watchProcesses(refreshTime: UInt32) {
        isWatching = true
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            while (self.isWatching) {
                sleep(refreshTime)
                let deadlock = self.searchDeadLock()
                if (deadlock.count > 0) {
                    self.displayLog("Deadlock with \(deadlock)")
                }
            }
        }
    }
    
    func printLocatedReasorces() {
        print("+==========================+")
        for p in processes.keys.sorted(by: <) {
            var pMessenge = "\(getTime()) - \(processes[p]!.id): "
            for r in processes[p]!.allocatedResourcesCount.keys.sorted(by: <) {
                pMessenge.append("\(r) -> \(processes[p]!.allocatedResourcesCount[r]!) ")
            }
            pMessenge.append("\(processes[p]!.disiredResource)  \(processes[p]!.isCancelled ? "cancelado" : "")")
            print(pMessenge)
        }
    }
    
    func registerResouce (resouceId: Int, resouce: Resource) {
        resources[resouceId] = resouce
        
        for p in processes.values {
            p.registerResouce(resouceId: resouceId, resouce: resouce)
        }
        displayRegisterResource(resouceId, resouce)
    }
    
    func registerProcess (process: Process) {
        processes[process.id] = process
        process.start()
    }
    
    var displayLog: (String) -> Void = {_ in}
    var displayRegisterResource: (Int, Resource) -> Void = {_, _ in}
}

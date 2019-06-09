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
    var resourcesTable: [Int: Resource]
    var isWatching = false
    
    init(resourcesTable: [Int: Resource], processes: [Int: Process]) {
        self.processes = processes
        self.resourcesTable = resourcesTable
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
            let desiredResouce = resourcesTable[desiredResouceId]!
            desiredResouce.cancelGive(processId: id)
        }
        processes[id] = nil
    }
    
    func searchDeadLock() -> [Int] {
        let avalibleResouces = resourcesTable.compactMap{$0.value.quantity > 0 ? $0.key : nil}
        let processesWithRequest = processes.filter{ $0.value.disiredResource != nil }
        let blockedProcesses = processesWithRequest.filter{
            !avalibleResouces.contains($0.value.disiredResource ?? -99) || $0.value.disiredResource != nil }
        
        var blockedReasouces: [Int] = []
        for i in 0..<blockedProcesses.count {
            let p = Array(blockedProcesses.values)[i]
            blockedReasouces.append(contentsOf: p.allocatedResourcesCount.compactMap{$0.value > 0 ? $0.key : nil})
        }
        blockedReasouces = Array(Set(blockedReasouces))
        
        let deadlock = blockedProcesses.filter {blockedReasouces.contains($0.value.disiredResource ?? -99)}
        
        return Array(deadlock.keys)
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
        resourcesTable[resouceId] = resouce
        
        for p in processes.values {
            p.registerResouce(resouceId: resouceId, resouce: resouce)
        }
        displayRegisterResource(resouceId, resouce)
    }
    
    func addProcess (processId: Int, process: Process) {
        processes[processId] = process
        process.start()
    }
    
    var displayLog: (String) -> Void = {_ in}
    var displayRegisterResource: (Int, Resource) -> Void = {_, _ in}
}

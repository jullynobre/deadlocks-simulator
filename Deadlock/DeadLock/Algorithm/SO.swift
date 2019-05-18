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
    let resourcesTable: [Int: Resource]
    var isWatching = true
    
    init(resourcesTable: [Int: Resource], processes: [Int: Process]) {
        self.processes = processes
        self.resourcesTable = resourcesTable
    }
    
    func alocationMatrix() -> [Int: [Int: Int]] {
        var alocationMatrix = [Int: [Int:Int]]()
        for p in processes.keys.sorted(by: <) {
            alocationMatrix[p] = processes[p]!.acquiredResoucesCount
        }
        return alocationMatrix
    }
    
    func killProcess(id: Int) {
        if (!processes.keys.contains(id)) {
            print("id inválido")
        } else {
            let process = processes[id]!
            let processResoucersHistory = process.resoucersHistory
            process.cancel()
            for r in processResoucersHistory {
                process.removeOldest()
            }
        }
    }
    
    func hasDeadLock() -> Bool {
        let avalibleResouces = resourcesTable.compactMap{$0.value.quantity > 0 ? $0.key : nil}
        let processesWithRequest = processes.filter{ $0.value.disiredResource != nil }
        let blockedProcesses = processesWithRequest.filter{
            !avalibleResouces.contains($0.value.disiredResource ?? -99) || $0.value.disiredResource != nil }
        return blockedProcesses.count == processes.count
    }
    
    func watchProcesses(refreshTime: UInt32) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            while (self.isWatching) {
                sleep(refreshTime)
                self.printLocatedReasorces()
                if (self.hasDeadLock()) {
                    self.onDeadLock(self)
                }
            }
        }
    }
    
    func printLocatedReasorces() {
        print("+==========================+")
        for p in processes.keys.sorted(by: >) {
            var pMessenge = "\(getTime()) - \(processes[p]!.id): "
            for r in processes[p]!.acquiredResoucesCount.keys.sorted(by: >) {
                pMessenge.append("\(processes[p]!.acquiredResoucesCount[r]!) ")
            }
            pMessenge.append("\(processes[p]!.disiredResource)  \(processes[p]!.isCancelled ? "cancelado" : "")")
            print(pMessenge)
        }
    }
    
    var onDeadLock: ((SO) -> Void) = {(self) in
        print("DeadLock !!!")
        for p in self.processes {
            print("\(p.key) -> \(p.value.acquiredResoucesCount)")
        }
    }
}

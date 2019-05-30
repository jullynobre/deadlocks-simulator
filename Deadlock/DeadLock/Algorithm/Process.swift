//
//  Process.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 10/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Foundation


class Process: Thread {
    
    let id: Int
    let ts: Double
    let tu: Double
    var resourcesTable: [Int: Resource]
    
    var resoucersHistory: [Int] = []
    var acquiredResoucesCount: [Int: Int]
    var disiredResource: Int?
    
    var isAlive: Bool = true
    
    let viewController: ViewController
    
    init(id: Int, ts: Double, tu: Double, resourcesTable: [Int: Resource], viewController: ViewController) {
        self.id = id
        self.ts = ts
        self.tu = tu
        self.resourcesTable = resourcesTable
        self.acquiredResoucesCount = resourcesTable.mapValues({_ in 0})
        self.viewController = viewController
    }
    
    func hasResouces() -> Bool {
        return !resoucersHistory.isEmpty
    }
    
    func chooseResouce() -> Int {
        var elegibleReasorces: [Int] = []
        
        for r in self.resourcesTable.keys {
            if resourcesTable[r]!.maxQuantity > acquiredResoucesCount[r]! {
                elegibleReasorces.append(r)
            }
        }
        
        if (elegibleReasorces.count == 0) {
            say("Não há mais recursos para requisitar!!!\n")
            Thread.sleep(forTimeInterval: 5.0)
            return chooseResouce()
        } else {
            return elegibleReasorces.randomElement()!
        }
    }
    
    func say(_ messenge: String) {
        let m = "\(getTime()) - P. \(self.id): \(messenge)\n\n"
        print(m)
        DispatchQueue.main.async {
            self.viewController.consoleScrollView.documentView!.insertText(m)
        }
    }
    
    func store(resouceId: Int) {
        resoucersHistory.append(resouceId)
        let resCount = acquiredResoucesCount[resouceId] ?? 0
        acquiredResoucesCount[resouceId] = 1 + resCount
    }
    
    func removeOldest() {
        let resourceId: Int = resoucersHistory[0]
        resourcesTable[resourceId]!.retrive()
        acquiredResoucesCount[resourceId] = acquiredResoucesCount[resourceId]! - 1
        resoucersHistory.removeFirst()
    }
    
    override func main() {
        var timeToEndConsume = 0.0
        var timeToAsk = ts
        
        while (!self.isCancelled) {
            // Calc sleeping time
            var sleepingTime: Double
            if (self.hasResouces()) {
                sleepingTime = timeToEndConsume > timeToAsk ? timeToAsk : timeToEndConsume
            } else {
                sleepingTime = timeToAsk
            }
            // Sleep
            Thread.sleep(forTimeInterval: sleepingTime)
            
            // Calc new time to actions
            if (self.hasResouces()) {
                timeToEndConsume -= sleepingTime
            }
            timeToAsk -= sleepingTime
            
            // Give back resouce
            if (timeToEndConsume == 0.0 && self.hasResouces()) {
                self.say("Liberando \(self.resourcesTable[self.resoucersHistory[0]]!.name)")
                self.removeOldest()
            }
            // Ask Resouce
            if (timeToAsk == 0.0) {
                self.disiredResource = self.chooseResouce()
                
                self.say("Requisitando \(self.resourcesTable[self.disiredResource!]!.name)")
                
                self.resourcesTable[self.disiredResource!]!.give(processId: self.id)
                
                self.say("Adquirido \(self.resourcesTable[self.disiredResource!]!.name)")
                
                self.store(resouceId: self.disiredResource!)
                
                self.disiredResource = nil
            }
            
            // Reset counters
            timeToAsk = timeToAsk == 0.0 ? self.ts : timeToAsk
            timeToEndConsume = timeToEndConsume == 0.0 && self.hasResouces() ? self.tu : timeToEndConsume
        }
        
        for _ in self.resoucersHistory {
            self.removeOldest()
        }
    }
}

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
    var resources: [Int: Resource]
    
    var allocatedResourcesCount: [Int: Int]
    var disiredResource: Int?
    
    var consumeCounters: [ConsumeCounter] = []
    
    init(id: Int, ts: Double, tu: Double, resources: [Int: Resource]) {
        self.id = id
        self.ts = ts
        self.tu = tu
        self.resources = resources
        self.allocatedResourcesCount = resources.mapValues({_ in 0})
    }
    
    func chooseResouce() -> Int? {
        var elegibleReasorces: [Int] = []
        
        for r in resources.keys {
            if resources[r]!.maxQuantity > allocatedResourcesCount[r]! {
                elegibleReasorces.append(r)
            }
        }
        
        if (elegibleReasorces.count == 0) {
            displayLog("Não há mais recursos para requisitar!!!")
            return nil
        } else {
            let r = elegibleReasorces.randomElement()!
            displayWantedResource(r)
            return r
        }
    }
    
    func store(resouceId: Int) {
        let resCount = allocatedResourcesCount[resouceId] ?? 0
        allocatedResourcesCount[resouceId] = 1 + resCount
        consumeCounters.append(ConsumeCounter(resouceId: resouceId, remaningTime: tu))
        
        displayWantedResource(nil)
        displayAllocatedResouceCount(resouceId, allocatedResourcesCount[resouceId]!)
    }
    
    func retrive(resourceId: Int) {
        let resCount = allocatedResourcesCount[resourceId]!
        allocatedResourcesCount[resourceId] = resCount - 1
        
        let counterIndex = consumeCounters.firstIndex{$0.resouceId == resourceId}
        consumeCounters.remove(at: counterIndex!)
        
        resources[resourceId]?.retrive()
        
        displayLog("Liberando \(resources[resourceId]!.name)")
        displayAllocatedResouceCount(resourceId, allocatedResourcesCount[resourceId]!)
    }
    
    override func main() {
        var timeToAsk = ts
        
        self.displayStartProcess()
        while (!self.isCancelled) {
            // Calc sleeping time
            let sleepingTime: Double
            if (!consumeCounters.isEmpty) {
                let timeToEndConsume = consumeCounters[0].remaningTime
                sleepingTime = timeToEndConsume > timeToAsk ? timeToAsk : timeToEndConsume
            } else {
                sleepingTime = timeToAsk
            }
            // Sleep
            Thread.sleep(forTimeInterval: sleepingTime)
            
            // Calc new time to actions
            for i in consumeCounters.indices {
                consumeCounters[i].remaningTime -= sleepingTime
            }
            timeToAsk -= sleepingTime
            
            // Give back resouce
            let doneReasorcesCounters = consumeCounters.filter{$0.remaningTime == 0}
            for resouceCounter in doneReasorcesCounters {
                let resourceId = resouceCounter.resouceId
                retrive(resourceId: resourceId)
            }
            // Ask Resouce
            if (timeToAsk == 0.0) {
                self.disiredResource = self.chooseResouce()
                if (disiredResource != nil) {
                    self.displayLog("Requisitando \(self.resources[self.disiredResource!]!.name)")
                    
                    self.resources[self.disiredResource!]!.give(processId: self.id)
                    
                    self.displayLog("Adquirido \(self.resources[self.disiredResource!]!.name)")
                    self.store(resouceId: self.disiredResource!)
                    self.disiredResource = nil
                }
            }
            
            // Reset ask counter
            timeToAsk = timeToAsk == 0.0 ? self.ts : timeToAsk
        }
        // Finishing Process
        for counter in self.consumeCounters {
            resources[counter.resouceId]?.retrive()
        }
        displayEndProcess()
        
    }
    
    func registerResouce(resouceId: Int, resouce: Resource) {
        resources[resouceId] = resouce
        allocatedResourcesCount[resouceId] = 0
    }
    
    var displayWantedResource: (Int?) -> Void = {_ in}
    var displayLog: (String) -> Void = {_ in}
    var displayAllocatedResouceCount: (_ resourceId: Int, _ resourceQuantity: Int) -> Void = {(resourceId: Int, resourceQuantity: Int) in}
    var displayEndProcess: () -> Void = {}
    var displayStartProcess: () -> Void = {}
}


struct ConsumeCounter {
    let resouceId: Int
    var remaningTime: Double
}

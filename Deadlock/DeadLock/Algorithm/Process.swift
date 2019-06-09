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
    
    let viewController: ViewController
    
    init(id: Int, ts: Double, tu: Double, resources: [Int: Resource], viewController: ViewController) {
        self.id = id
        self.ts = ts
        self.tu = tu
        self.resources = resources
        self.allocatedResourcesCount = resources.mapValues({_ in 0})
        self.viewController = viewController
        
        // setup view elements
        let processView = self.viewController.processesViews[id]
        processView.activateProcess(id: id, ts: Int(ts), tu: Int(tu))
        
        viewController.processesIdLabels[id].activate(id)
        for resouce in allocatedResourcesCount.keys {
            viewController.acquiredResoucesLabels[id][resouce].activate(0)
        }
    }
    
    func chooseResouce() -> Int {
        var elegibleReasorces: [Int] = []
        
        for r in resources.keys {
            if resources[r]!.maxQuantity > allocatedResourcesCount[r]! {
                elegibleReasorces.append(r)
            }
        }
        
        if (elegibleReasorces.count == 0) {
            say("Não há mais recursos para requisitar!!!\n")
            Thread.sleep(forTimeInterval: 5.0)
            return chooseResouce()
        } else {
            let r = elegibleReasorces.randomElement()!
            DispatchQueue.main.async {
                self.viewController.wantedResourcesLabels[self.id].activate(r)
            }
            return r
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
        let resCount = allocatedResourcesCount[resouceId] ?? 0
        allocatedResourcesCount[resouceId] = 1 + resCount
        consumeCounters.append(ConsumeCounter(resouceId: resouceId, remaningTime: tu))
        DispatchQueue.main.async {
            self.viewController.wantedResourcesLabels[self.id].deactivate()
            self.viewController.acquiredResoucesLabels[self.id][resouceId].activate(self.allocatedResourcesCount[resouceId]!)
        }
    }
    
    func retrive(resourceId: Int) {
        let resCount = allocatedResourcesCount[resourceId]!
        allocatedResourcesCount[resourceId] = resCount - 1
        
        let counterIndex = consumeCounters.firstIndex{$0.resouceId == resourceId}
        consumeCounters.remove(at: counterIndex!)
        
        resources[resourceId]?.retrive()
        
        self.say("Liberando \(self.resources[resourceId]!.name)")
        DispatchQueue.main.async {
            self.viewController.acquiredResoucesLabels[self.id][resourceId].activate(self.allocatedResourcesCount[resourceId]!)
        }
    }
    
    override func main() {
        var timeToAsk = ts
        
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
                
                self.say("Requisitando \(self.resources[self.disiredResource!]!.name)")
                
                self.resources[self.disiredResource!]!.give(processId: self.id)
                
                self.say("Adquirido \(self.resources[self.disiredResource!]!.name)")
                
                self.store(resouceId: self.disiredResource!)
                
                self.disiredResource = nil
            }
            
            // Reset ask counter
            timeToAsk = timeToAsk == 0.0 ? self.ts : timeToAsk
        }
        
        for i in self.consumeCounters.indices {
            let resourceId = consumeCounters[i].resouceId
            resources[resourceId]?.retrive()
        }
        DispatchQueue.main.async {
            self.viewController.processesIdLabels[self.id].deactivate()
            self.viewController.wantedResourcesLabels[self.id].deactivate()
            self.viewController.processesViews[self.id].deactivateProcess()
        }
        
        for resource in allocatedResourcesCount.keys {
            viewController.acquiredResoucesLabels[id][resource].deactivate()
        }
    }
    
    func addResouce(resouceId: Int, resouce: Resource) {
        resources[resouceId] = resouce
        allocatedResourcesCount[resouceId] = 0
    }
    
    var 
}


struct ConsumeCounter {
    let resouceId: Int
    var remaningTime: Double
}

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
    var resourcesses: [Int: Resource]
    
    var acquiredResourcesCount: [Int: Int]
    var disiredResource: Int?
    
    var consumeCounters: [ConsumeCounter] = []
    
    let view: ViewController
    
    init(id: Int, ts: Double, tu: Double, resourcesses: [Int: Resource], view: ViewController) {
        self.id = id
        self.ts = ts
        self.tu = tu
        self.resourcesses = resourcesses
        self.acquiredResourcesCount = resourcesses.mapValues({_ in 0})
        self.view = view
        
        // setup view elements
        let processView = self.view.processesViews[id]
        processView.activateProcess(id: id, ts: Int(ts), tu: Int(tu))
        
        view.processesIdLabels[id].activate(id)
        for resouce in acquiredResourcesCount.keys {
            view.acquiredResoucesLabels[id][resouce].activate(0)
        }
    }
    
    func chooseResouce() -> Int {
        var elegibleReasorces: [Int] = []
        
        for r in self.resourcesses.keys {
            if resourcesses[r]!.maxQuantity > acquiredResourcesCount[r]! {
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
                self.view.wantedResourcesLabels[self.id].activate(r)
            }
            return r
        }
    }
    
    func say(_ messenge: String) {
        let m = "\(getTime()) - P. \(self.id): \(messenge)\n\n"
        print(m)
        DispatchQueue.main.async {
            self.view.consoleScrollView.documentView!.insertText(m)
        }
    }
    
    func store(resouceId: Int) {
        let resCount = acquiredResourcesCount[resouceId] ?? 0
        acquiredResourcesCount[resouceId] = 1 + resCount
        consumeCounters.append(ConsumeCounter(resouceId: resouceId, remaningTime: tu))
        DispatchQueue.main.async {
            self.view.wantedResourcesLabels[self.id].deactivate()
            self.view.acquiredResoucesLabels[self.id][resouceId].activate(self.acquiredResourcesCount[resouceId]!)
        }
    }
    
    func retrive(resourceId: Int) {
        let resCount = acquiredResourcesCount[resourceId]!
        acquiredResourcesCount[resourceId] = resCount - 1
        
        let counterIndex = consumeCounters.firstIndex{$0.resouceId == resourceId}
        consumeCounters.remove(at: counterIndex!)
        
        resourcesses[resourceId]?.retrive()
        
        self.say("Liberando \(self.resourcesses[resourceId]!.name)")
        DispatchQueue.main.async {
            self.view.acquiredResoucesLabels[self.id][resourceId].activate(self.acquiredResourcesCount[resourceId]!)
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
                
                self.say("Requisitando \(self.resourcesses[self.disiredResource!]!.name)")
                
                self.resourcesses[self.disiredResource!]!.give(processId: self.id)
                
                self.say("Adquirido \(self.resourcesses[self.disiredResource!]!.name)")
                
                self.store(resouceId: self.disiredResource!)
                
                self.disiredResource = nil
            }
            
            // Reset ask counter
            timeToAsk = timeToAsk == 0.0 ? self.ts : timeToAsk
        }
        
        for i in self.consumeCounters.indices {
            let resourceId = consumeCounters[i].resouceId
            resourcesses[resourceId]?.retrive()
        }
        DispatchQueue.main.async {
            self.view.processesIdLabels[self.id].deactivate()
            self.view.wantedResourcesLabels[self.id].deactivate()
            self.view.processesViews[self.id].deactivateProcess()
        }
        
        for resource in acquiredResourcesCount.keys {
            view.acquiredResoucesLabels[id][resource].deactivate()
        }
    }
    
    func addResouce(resouceId: Int, resouce: Resource) {
        resourcesses[resouceId] = resouce
        acquiredResourcesCount[resouceId] = 0
    }
}


struct ConsumeCounter {
    let resouceId: Int
    var remaningTime: Double
}

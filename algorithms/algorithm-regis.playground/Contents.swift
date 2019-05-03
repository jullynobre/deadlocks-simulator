import Cocoa



class Resource {
    
    let name: String
    
    let quantitySemaphore: DispatchSemaphore
    var quantity: Int
    let maxQuantity: Int
    
    let mutex: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    init (name: String, quantity: Int) {
        self.name = name
        self.quantitySemaphore = DispatchSemaphore(value: quantity)
        self.quantity = quantity
        self.maxQuantity = quantity
    }
    
    func give() {
        quantitySemaphore.wait()
        
        mutex.wait()
        quantity -= 1
        mutex.signal()
    }
    
    func retrive() {
        quantitySemaphore.signal()
        
        mutex.wait()
        quantity += 1
        mutex.signal()
    }
}

class Process {
    
    let id: Int
    let ts: Int
    let tu: Int
    var resourcesTable: [Int: Resource]
    
    var resoucersHistory: [Int] = []
    var acquiredResoucesCount: [Int: Int]
    var disiredResource: Int?
    
    var isAlive: Bool = true
    
    init(id: Int, ts: Int, tu: Int, resourcesTable: [Int: Resource]) {
        self.id = id
        self.ts = ts
        self.tu = tu
        self.resourcesTable = resourcesTable
        self.acquiredResoucesCount = resourcesTable.mapValues({_ in 0})
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
            print("\nNão há mais recursos para requisitar!!!\n")
            sleep(20)
            return chooseResouce()
        } else {
            return elegibleReasorces.randomElement()!
        }
    }
    
    func say(_ messenge: String) {
        print("\(getTime()) - \(id): \(messenge)\n")
    }
    
    func store(resouceId: Int) {
        resoucersHistory.append(resouceId)
        let resCount = acquiredResoucesCount[resouceId] ?? 0
        acquiredResoucesCount[resouceId] = 1 + resCount
    }
    
    func removeOldest() {
        acquiredResoucesCount[resoucersHistory[0]] = acquiredResoucesCount[resoucersHistory[0]]! - 1
        resoucersHistory.removeFirst()
    }
    
    func run() {
        var timeToEndConsume = 0
        var timeToAsk = ts
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            while (self.isAlive) {
                // Calc sleeping time
                var sleepingTime: Int
                if (self.hasResouces()) {
                    sleepingTime = timeToEndConsume > timeToAsk ? timeToAsk : timeToEndConsume
                } else {
                    sleepingTime = timeToAsk
                }
                // Sleep
                sleep(UInt32(sleepingTime))
                
                // Calc new time to actions
                if (self.hasResouces()) {
                    timeToEndConsume -= sleepingTime
                }
                timeToAsk -= sleepingTime
                
                // Give back resouce
                if (timeToEndConsume == 0 && self.hasResouces()) {
                    let resourceId: Int = self.resoucersHistory[0]
                    
                    self.resourcesTable[resourceId]!.retrive()
                    
                    self.removeOldest()
                    
                    self.say("released \(self.resourcesTable[resourceId]!.name)")
                }
                // Ask Resouce
                if (timeToAsk == 0) {
                    self.disiredResource = self.chooseResouce()
                    
                    self.say("trying to get \(self.resourcesTable[self.disiredResource!]!.name)")
                    
                    self.resourcesTable[self.disiredResource!]!.give()
                    
                    self.say("got \(self.resourcesTable[self.disiredResource!]!.name)")
                    
                    self.store(resouceId: self.disiredResource!)
                }
                
                // Reset counters
                timeToAsk = timeToAsk == 0 ? self.ts : timeToAsk
                timeToEndConsume = timeToEndConsume == 0 && self.hasResouces() ? self.tu : timeToEndConsume
            }
            // retrive all resouces
            for r in self.resoucersHistory {
                self.resourcesTable[r]!.retrive()
            }
        }
    }
}

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
    
    func say (_ messenge: Any) {
        print("\(getTime()) - SO: \(messenge)")
    }
    
    func killProcess(id: Int) {
        if (!processes.keys.contains(id)) {
            print("id inválido")
        } else {
            processes[id]!.isAlive = false
        }
    }
    
    func seakDeadLocks() -> [Int] {
        let avalibleReasorces = resourcesTable.compactMap{ $0.value.quantity > 0 ? $0.key : nil }
        let blockedProcesses = processes.compactMap{ avalibleReasorces.contains($0.value.disiredResource ?? -1) ? nil : $0.value }
        let readyProcesses = processes.compactMap{ avalibleReasorces.contains($0.value.disiredResource ?? -1) ? $0.value : nil }
        let securedResourcesInReadyProcess = Set<Int>(readyProcesses.map {$0.acquiredResoucesCount.compactMap {$0.value > 0 ? $0.key : nil}}.flatMap{ $0 })
        
        return blockedProcesses.compactMap{
            if ($0.disiredResource != nil) {
                return securedResourcesInReadyProcess.contains($0.disiredResource!) ? nil : $0.id
            } else {
                return nil
            }
        }
    }
    
    func watchProcesses(refreshTime: UInt32) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            while (self.isWatching) {
                sleep(refreshTime)
                let deadLock = self.seakDeadLocks()
                
                if !deadLock.isEmpty {
                    print("Found deadlocks with \(deadLock.description)")
                }
            }
        }
    }
}

func getTime() -> String {
    let now = Date()
    
    let formatter = DateFormatter()
    
    formatter.timeZone = TimeZone.current
    
    formatter.dateFormat = "HH:mm:ss"
    
    return formatter.string(from: now)
}

let resourcesTable: [Int: Resource] = [
        1: Resource(name: "impressora", quantity: 4),
        2: Resource(name: "Gravadora de DVD", quantity: 3),
        3: Resource(name: "Câmera", quantity: 2),
        4: Resource(name: "Plotter", quantity: 3)]

var processes: [Int: Process] = [
    1: Process(id: 1, ts: 3, tu: 5, resourcesTable: resourcesTable),
    2: Process(id: 2, ts: 2, tu: 3, resourcesTable: resourcesTable),
    3: Process(id: 3, ts: 3, tu: 2, resourcesTable: resourcesTable)
]

let so = SO(resourcesTable: resourcesTable, processes: processes)

for p in processes.values { p.run() }

so.watchProcesses(refreshTime: 1)

so.killProcess(id: 1)

// bug: quando um processo tem todos os recursos de um tipo, ele está sendo considerado como um deadlock nele mesmo

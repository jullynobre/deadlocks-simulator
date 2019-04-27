import Cocoa

class Resource {
	let name: String
	let id: Int
	
	let mutex = DispatchSemaphore(value: 1)
	let countSemaphore: DispatchSemaphore
	let count: Int
	
	init(id: Int, name: String, count: Int) {
		self.id = id
		self.name = name
		self.count = count
		self.countSemaphore = DispatchSemaphore(value: count)
	}
	
	func request() {
		self.countSemaphore.wait()
	}
	
	func release() {
		self.countSemaphore.signal()
	}
	
}

class Process {
	let id: Int
	let solicitInterval: Int
	let useInterval: Int
	
	var isAlive: Bool = true
	
	var gettedResources: [Int: Int] = [:]
	
	var fifoResources: [Resource] = []
	
	init(id: Int, solicitInterval: Int, useInterval: Int, isAlive: Bool = true) {
		self.id = id
		self.solicitInterval = solicitInterval
		self.useInterval = useInterval
		self.isAlive = isAlive
	}
	
	func run(resources: [Resource]) {
		DispatchQueue.main.async {
			var timeToGet = self.solicitInterval
			var timeToRelease = 0
			
			while(self.isAlive) {
				let timeToNextAction: Int
				if self.fifoResources.isEmpty { //next action is to get resource
					timeToNextAction = timeToGet
				} else {
					timeToNextAction = timeToGet < timeToRelease ? timeToGet : timeToRelease
				}
				
				timeToGet -= timeToNextAction
				timeToRelease -= self.fifoResources.isEmpty ? 0 : timeToNextAction
				
				if timeToRelease == 0 && !self.fifoResources.isEmpty {
					//relese
					timeToRelease += self.useInterval
				}
				if timeToGet == 0 {
					//get
					timeToGet += self.solicitInterval
				}
			}
		}
	}
}

struct OperationSystem {
	let timeInterval: Int
	
	init(timeInterval: Int) {
		self.timeInterval = timeInterval
	}
	
	func run() {
		DispatchQueue.main.async {
			while(true) {
				//logic
			}
		}
	}
}



//var resource = resources[Int.random(in: 0...resources.count)]
//if self.gettedResources.index(forKey: resource.id) != nil{
//	while self.gettedResources[resource.id]! >= resource.count {
//		resource = resources[Int.random(in: 0...resources.count)]
//	}
//}
//self.gettedResources.updateValue((self.gettedResources[resource.id] ?? 0) + 1,
//								 forKey: resource.id)
//
//resource.request()

//
//  Resouce.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 10/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Foundation


class Resource {
    
    let name: String
    
    let quantitySemaphore: DispatchSemaphore
    var quantity: Int
    let maxQuantity: Int
    
    let mutex: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private var simulatingGive: Bool = false
    private var canPickFalseReasouce: Int? = nil
    
    init (name: String, quantity: Int) {
        self.name = name
        self.quantitySemaphore = DispatchSemaphore(value: quantity)
        self.quantity = quantity
        self.maxQuantity = quantity
    }
    
    func give(processId: Int) {
        while true {
            quantitySemaphore.wait()
            if (simulatingGive && canPickFalseReasouce == processId) {
                simulatingGive = false
                canPickFalseReasouce = nil
            } else {
                break
            }
        }
        mutex.wait()
        quantity -= 1
        mutex.signal()
        
        displayAvalibleReasources(quantity)
    }
    
    func retrive() {
        quantitySemaphore.signal()
        
        mutex.wait()
        quantity += 1
        mutex.signal()
        
        displayAvalibleReasources(quantity)
    }
    
    func cancelGiveTo (processId: Int) {
        canPickFalseReasouce = processId
        simulatingGive = true
        
        var simulatedGiveCounter = 0
        while (simulatingGive) {
            simulatedGiveCounter += 1
            quantitySemaphore.signal()
        }
        
        for _ in 0..<simulatedGiveCounter-1 {
            quantitySemaphore.wait()
        }
    }
    
    var displayAvalibleReasources: (Int) -> Void = {_ in}
}

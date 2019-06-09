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
    private var canPickFalseReasouce: Int?
    
    let resourceView: ResourceView
    
    init (name: String, quantity: Int, view: ResourceView) {
        self.name = name
        self.quantitySemaphore = DispatchSemaphore(value: quantity)
        self.quantity = quantity
        self.maxQuantity = quantity
        self.resourceView = view
    }
    
    func give(processId: Int) {
        while true {
            quantitySemaphore.wait()
            if (simulatingGive && canPickFalseReasouce == processId) {
                simulatingGive = false
                canPickFalseReasouce = nil
                return
            } else {
                break
            }
        }
        mutex.wait()
        if(!simulatingGive) {
            quantity -= 1
        }
        mutex.signal()
        
        DispatchQueue.main.async {
            self.resourceView.updateAvailableLabel(newValue: String(self.quantity))
        }
    }
    
    func retrive() {
        quantitySemaphore.signal()
        
        mutex.wait()
        quantity += 1
        mutex.signal()
        
        DispatchQueue.main.async {
            self.resourceView.updateAvailableLabel(newValue: String(self.quantity))
        }
    }
    
    func cancelGive (processId: Int) {
        canPickFalseReasouce = processId
        simulatingGive = true
        while (simulatingGive) {
            quantitySemaphore.signal()
        }
    }
}

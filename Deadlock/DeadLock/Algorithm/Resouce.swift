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
    
    var simalatingGive: Bool = false
    var canPickFalseReasouce: Int?
    
    init (name: String, quantity: Int) {
        self.name = name
        self.quantitySemaphore = DispatchSemaphore(value: quantity)
        self.quantity = quantity
        self.maxQuantity = quantity
    }
    
    func give(processId: Int) {
        while true {
            quantitySemaphore.wait()
            if (!simalatingGive || canPickFalseReasouce == processId) {
                simalatingGive = false
                canPickFalseReasouce = -99
                break
            }
        }
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

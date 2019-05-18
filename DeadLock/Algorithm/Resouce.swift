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

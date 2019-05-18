//
//  GetTime.swift
//  DeadLock
//
//  Created by Régis Melgaço de Andrade on 10/05/19.
//  Copyright © 2019 Régis Melgaço de Andrade. All rights reserved.
//

import Foundation


func getTime() -> String {
    let now = Date()
    
    let formatter = DateFormatter()
    
    formatter.timeZone = TimeZone.current
    
    formatter.dateFormat = "HH:mm:ss"
    
    return formatter.string(from: now)
}

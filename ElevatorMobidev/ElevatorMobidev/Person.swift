//
//  Person.swift
//  ElevatorMobidev
//
//  Created by Admin on 13.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class Person : NSObject {
    
    let destinationFloor:Int
    let startFloor:Int
    let direction:Direction!
    
    init(destinationFloor:Int,startFloor:Int)
    {
        self.destinationFloor = destinationFloor
        self.startFloor = startFloor
        self.direction = self.destinationFloor > self.startFloor ? .UP : .DOWN
        
        super.init()
    }
    
}
extension Person : PrintSelf
{
    func printSelf() -> String {
        return " \(self.direction.rawValue)\(self.destinationFloor) "
    }
}
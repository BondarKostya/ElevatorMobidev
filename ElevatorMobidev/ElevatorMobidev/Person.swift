//
//  Person.swift
//  ElevatorMobidev
//
//  Created by Admin on 13.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class Person : NSObject {
    
    var destinationFloor = 1
    var startFloor = 1
    var direction:Direction!
    
    init(destinationFloor:Int,startFloor:Int)
    {
        super.init()
        self.initProperties(destinationFloor, startFloor: startFloor)
    }
    
    func initProperties(destinationFloor:Int,startFloor:Int)
    {
        self.destinationFloor = destinationFloor
        self.startFloor = startFloor
        self.direction = self.destinationFloor > self.startFloor ? .UP : .DOWN
    }
    
    func changeFloors(destinationFloor:Int,startFloor:Int)
    {
        self.initProperties(destinationFloor, startFloor: startFloor)
    }
    
}
extension Person : PrintSelf
{
    func printSelf() -> String {
        return " \(self.direction.rawValue)\(self.destinationFloor) "
    }
}
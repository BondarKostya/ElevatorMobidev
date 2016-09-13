//
//  Floor.swift
//  ElevatorMobidev
//
//  Created by Admin on 13.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class Floor : NSObject
{
    let floorNumber:Int
    var peoples:[Person]
    
    init(floorNumber:Int,peoples:[Person])
    {
        self.floorNumber = floorNumber
        self.peoples = peoples
    }
}

extension Floor : PrintSelf
{
    func printSelf() -> String {
        var peoplesPrint = ""
        for person in self.peoples
        {
            peoplesPrint = "\(peoplesPrint) \(person.printSelf())"
        }
        return "fl\(self.floorNumber):\(peoplesPrint)"
    }
}
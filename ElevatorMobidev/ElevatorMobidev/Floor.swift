//
//  Floor.swift
//  ElevatorMobidev
//
//  Created by Admin on 13.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class Floor: NSObject
{
    let floorNumber:Int
    var persons:[Person]
    
    init(floorNumber:Int,persons:[Person])
    {
        self.floorNumber = floorNumber
        self.persons = persons
        
        super.init()
    }
}

extension Floor : PrintSelf
{
    func printSelf() -> String {
        var personsPrint = ""
        for person in self.persons
        {
            personsPrint = "\(personsPrint) \(person.printSelf())"
        }
        return "fl\(self.floorNumber):\(personsPrint)"
    }
}
//
//  ApplicationDirector.swift
//  ElevatorMobidev
//
//  Created by Admin on 13.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class ApplicationDirector : NSObject
{
    func executeApplication()
    {
        let building = Building(floorsCount: Int.random(5...20))
        building.launchElevator()
        
        ConsoleWrapper.objectsForPrint.insertObject(building, atIndex: 0)
        ConsoleWrapper.rePrintConsole()
    }
    

}

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
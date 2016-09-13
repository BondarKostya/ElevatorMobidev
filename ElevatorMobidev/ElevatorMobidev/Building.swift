//
//  Building.swift
//  ElevatorMobidev
//
//  Created by Admin on 13.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class Building : NSObject
{
    var floors : [Floor]
    var elevator : Elevator?
    init(floorsCount: Int)
    {
        self.floors = [Floor]()
        
        super.init()
        
        for floorNumber in 1...floorsCount {
            var peoplesOnFloor = [Person]()
            for _ in 0...Int.random(0...9)
            {
                var destFloor = floorNumber
                while destFloor == floorNumber
                {
                    destFloor = Int.random(1...floorsCount)
                }
                peoplesOnFloor.append(Person(destinationFloor: destFloor, startFloor: floorNumber))
                
            }
            let floor = Floor(floorNumber: floorNumber,peoples: peoplesOnFloor)
            self.floors.append(floor)
            
        }
        self.elevator = Elevator(maxFloor: self.floors.count,building:self)
        ConsoleWrapper.objectsForPrint.insertObject(self.elevator!, atIndex: 0)
    }
    
    func needToStopOnFloor(floorNumber:Int,direction:Direction,responce:(answer:Bool) -> Void)
    {
        
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
        }[0]
        
        for person in floor.peoples
        {
            if person.direction == direction
            {
                responce(answer:true)
                return;
            }
        }
    }
    
    func getMostPeople(floorNumber:Int) -> (direction:Direction,peoples:[Person])
    {
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
        }[0]
        
        let upDirectionPeople = floor.peoples.filter {
            $0.direction == Direction.UP ? true : false
        }
        let downDirectionPeople = floor.peoples.filter {
            $0.direction == Direction.DOWN ? true : false
        }
        if upDirectionPeople.count > downDirectionPeople.count
        {
            self.removePeopleFromFloor(floorNumber, people: Array(upDirectionPeople.prefix(5)))
            return (.UP,Array(upDirectionPeople.prefix(5)))
        }
        else
        {
            self.removePeopleFromFloor(floorNumber, people: Array(downDirectionPeople.prefix(5)))
            return (.DOWN,Array(downDirectionPeople.prefix(5)))
        }
    }
    
    func getPeople(floorNumber:Int,direction:Direction,personCount:Int) -> [Person]
    {
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
        }[0]
        
        var directionPeople = floor.peoples.filter {
            $0.direction == direction ? true : false
        }
        directionPeople =  Array(directionPeople.prefix(personCount));
        self.removePeopleFromFloor(floorNumber, people: directionPeople)
        return directionPeople
    }
    
    func removePeopleFromFloor(floorNumber:Int, people:[Person])
    {
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
        }[0]
        for (index,person) in floor.peoples.enumerate().reverse()
        {
            if let _ = people.indexOf(person)
            {
                floor.peoples.removeAtIndex(index)
            }
        }
    }
    
    func getNerbyPersonFloor(floorNumber:Int) -> Int
    {
        var deltaFloorNumber = self.floors.count;
        var nearbyFloor = 1;
        for floor in self.floors {
            if(floor.peoples.count > 0)
            {
                if(abs(floor.floorNumber - floorNumber) < deltaFloorNumber)
                {
                    deltaFloorNumber = abs(floor.floorNumber - floorNumber)
                    nearbyFloor = floor.floorNumber
                }
            }

        }
        return nearbyFloor
    }
    
    func havePeoplesOnFloors() -> Bool
    {
        for floor in self.floors {
            if floor.peoples.count > 0
            {
               return true
            }
        }
        return false
    }
    
    func launchElevator()
    {
        
    }
}

extension Building : PrintSelf
{
    func printSelf() -> String {
        var buildingDescription = "Floors count : \(self.floors.count)"
        for floor in self.floors
        {
            if elevator?.currentFloor == floor.floorNumber
            {
               buildingDescription = "\(buildingDescription)\n🚪\(floor.printSelf())"
            }
            else
            {
               buildingDescription = "\(buildingDescription)\n  \(floor.printSelf())"
            }
            
        }
        
        return buildingDescription
    }
    
}
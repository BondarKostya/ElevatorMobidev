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
    // MARK: Properties
    var floors : [Floor]
    var elevator : Elevator?
    var floorsCount:Int
    
    // MARK: - Init building
    init(floorsCount: Int)
    {
        self.floors = [Floor]()
        self.floorsCount = floorsCount
        super.init()
        
        for floorNumber in 1...self.floorsCount {
            var personsOnFloor = [Person]()
            
            //creating random persons for floor
            for _ in 0...Int.random(0...(Constants.maxPersons - 1))
            {
                //find not current floorNumber
                var destFloor = floorNumber
                while destFloor == floorNumber
                {
                    destFloor = Int.random(1...self.floorsCount)
                }
                personsOnFloor.append(Person(destinationFloor: destFloor, startFloor: floorNumber))
                
            }
            
            let floor = Floor(floorNumber: floorNumber,persons: personsOnFloor)
            self.floors.append(floor)
            
        }
        
        //creating elevator
        self.elevator = Elevator(maxFloor: self.floors.count,building:self)
        
        //add elevator to the console print objects in to top position
        ConsoleWrapper.objectsForPrint.insertObject(self.elevator!, atIndex: 0)
    }
    
    func launchElevator()
    {
        self.elevator?.launchElevator()
    }

    // MARK: Get persons through the requests
    //return touple with direction and person array
    func getMostPersons(floorNumber:Int) -> (direction:Direction,persons:[Person])
    {
        let floor = self.neededFloor(floorNumber)
        
        let upDirectionPersons = floor.persons.filter {
            $0.direction == Direction.UP ? true : false
        }
        let downDirectionPersons = floor.persons.filter {
            $0.direction == Direction.DOWN ? true : false
        }
        
        //find what direction is dominant and return data
        if upDirectionPersons.count > downDirectionPersons.count
        {
            self.removePersonFromFloor(floorNumber, persons: Array(upDirectionPersons.prefix(5)))
            return (.UP,Array(upDirectionPersons.prefix(Constants.maxPersonInElevator)))
        }
        else
        {
            self.removePersonFromFloor(floorNumber, persons: Array(downDirectionPersons.prefix(5)))
            return (.DOWN,Array(downDirectionPersons.prefix(Constants.maxPersonInElevator)))
        }
    }
    
    func getPersons(floorNumber:Int,direction:Direction,personCount:Int) -> [Person]
    {
        let floor = self.neededFloor(floorNumber)
        
        var directionPersons = floor.persons.filter {
            $0.direction == direction ? true : false
        }
        directionPersons =  Array(directionPersons.prefix(personCount));
        
        self.removePersonFromFloor(floorNumber, persons: directionPersons)
        return directionPersons
    }
    
    //MARK: Add person to floor and regenerate destination floor
    func addPersonToFloorAndRegenerateDestFloor(floorNumber:Int,person:Person)
    {
        let floor = self.neededFloor(floorNumber)
        var destFloor = floorNumber
        while destFloor == floorNumber
        {
            destFloor = Int.random(1...floorsCount)
        }
        person.changeFloors(destFloor, startFloor: floor.floorNumber)
        floor.persons.append(person)
    }
    
    // MARK: Remove person
    func removePersonFromFloor(floorNumber:Int, persons:[Person])
    {
        let floor = self.neededFloor(floorNumber)
        
        //safe, reverce removing from array
        for (index,person) in floor.persons.enumerate().reverse()
        {
            //check if the person to remove, containts in floor persons
            if let _ = persons.indexOf(person)
            {
                floor.persons.removeAtIndex(index)
            }
        }
    }
    
    //MARK: Get needed floor
    func neededFloor(floorNumber:Int) -> Floor
    {
        //find the current floor throught the array filtering
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
            }[0]
        return floor;
    }
    
    //MARK: Checks
    //demonstrate work with <block> , better write this method without <block>
    func needToStopOnFloor(floorNumber:Int,direction:Direction,responce:(answer:Bool) -> Void)
    {
        
        let floor = self.neededFloor(floorNumber)
        
        //return persons with same direction
        for person in floor.persons
        {
            if person.direction == direction
            {
                responce(answer:true)
                return;
            }
        }
    }
    
    func getNerbyPersonFloor(floorNumber:Int) -> Int
    {
        var deltaFloorNumber = self.floors.count;
        var nearbyFloor = 1;
        //calculate nearby floor with abs method
        for floor in self.floors {
            if(floor.persons.count > 0)
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
    
    func havePersonsOnFloors() -> Bool
    {
        for floor in self.floors {
            if floor.persons.count > 0
            {
               return true
            }
        }
        return false
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
               buildingDescription = "\(buildingDescription)\n🚪\t\(floor.printSelf())"
            }
            else
            {
               buildingDescription = "\(buildingDescription)\n\t\(floor.printSelf())"
            }
            
        }
        
        return buildingDescription
    }
    
}
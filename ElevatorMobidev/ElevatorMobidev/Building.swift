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
    
    // MARK: - Init building
    init(floorsCount: Int)
    {
        self.floors = [Floor]()
        
        super.init()
        
        for floorNumber in 1...floorsCount {
            var peoplesOnFloor = [Person]()
            
            //creating random persons for floor
            for _ in 0...Int.random(0...(Constants.maxPersons - 1))
            {
                //find not current floorNumber
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
        
        //find what direction is dominant and return data
        if upDirectionPeople.count > downDirectionPeople.count
        {
            self.removePeopleFromFloor(floorNumber, people: Array(upDirectionPeople.prefix(5)))
            return (.UP,Array(upDirectionPeople.prefix(Constants.maxPersonInElevator)))
        }
        else
        {
            self.removePeopleFromFloor(floorNumber, people: Array(downDirectionPeople.prefix(5)))
            return (.DOWN,Array(downDirectionPeople.prefix(Constants.maxPersonInElevator)))
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
    
    // MARK: Remove person
    func removePeopleFromFloor(floorNumber:Int, people:[Person])
    {
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
        }[0]
        
        //safe, reverce removing from array
        for (index,person) in floor.peoples.enumerate().reverse()
        {
            //check if the person to remove, containts in floor peoples
            if let _ = people.indexOf(person)
            {
                floor.peoples.removeAtIndex(index)
            }
        }
    }
    
    //MARK: Checks
    //demonstrate work with <block> , better write this method without <block>
    func needToStopOnFloor(floorNumber:Int,direction:Direction,responce:(answer:Bool) -> Void)
    {
        //find the current floor throught the array filtering
        let floor = self.floors.filter {
            $0.floorNumber == floorNumber ? true : false
            }[0]
        
        //return persons with same direction
        for person in floor.peoples
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
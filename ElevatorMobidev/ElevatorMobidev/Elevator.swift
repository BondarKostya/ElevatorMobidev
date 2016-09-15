//
//  Elevator.swift
//  ElevatorMobidev
//
//  Created by Admin on 12.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

//MARK: Enums
//States of elevator
enum ElevatorState
{
    case MOVE_UP
    case MOVE_DOWN
    case STOP
    case EMPTY_MOVE
}

enum Direction : String
{
    case UP = "⬆"
    case DOWN = "⬇"
}

class Elevator:NSObject
{
    //MARK: Properties
    //need to weak ref for owner object
    weak var building:Building?
    var moveTimer:NSTimer!
    var currentFloor = 1
    var maxFloor:Int!
    let maxPersonCount = Constants.maxPersonInElevator
    var persons = [Person]()
    var outPersons = [Person]()
    var elevatorState = ElevatorState.STOP
    
    var direction = Direction.UP

    //MARK: - Init elevator
    init(maxFloor:Int,building:Building) {
        super.init()
        self.building = building
        self.maxFloor = maxFloor
        elevatorState = .STOP
        
    }
    func launchElevator()
    {
        self.startOrResumeTimer()
    }
    
    //MARK: Work with the timer
    
    func startOrResumeTimer()
    {
        moveTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.elevatorMoveTime, target: self, selector:#selector(Elevator.needToMove), userInfo: nil, repeats: true)
    }
    
    @objc func needToMove() {
        //do the elevators logic and reprint console (Building and Elevator)
        elevatorAction()
        
        ConsoleWrapper.rePrintConsole()
    }
    
    //MARK: Elevator actions

    
    func elevatorAction()
    {
        switch elevatorState {
        case .MOVE_UP:
            self.moveUpAction()
            break
        case .MOVE_DOWN:
            self.moveDownAction()
            break
        case .STOP:
            self.moveTimer.invalidate()
            self.stopAction()
            self.startOrResumeTimer()
            break
        case .EMPTY_MOVE:
            self.emptyMoveAction()
            break
        }
    }
    
    func moveUpAction()
    {
        if self.currentFloor  < self.maxFloor
        {
            self.currentFloor = self.currentFloor + 1
            self.direction = .UP
            self.askAction()

            
        }else
        {
            self.stopAction()
            self.direction = .DOWN
            self.checkForPersonsInBuilding(.DOWN)
        }
    }
    
    func moveDownAction()
    {
        if  self.currentFloor > 1
        {
            self.currentFloor = self.currentFloor - 1
            self.direction = .DOWN
            self.askAction()
            
        }else
        {
            self.stopAction()
            self.direction = .UP
            self.checkForPersonsInBuilding(.UP)
        }
    }
    
    func stopAction()
    {
        self.removePersonInNeededFloor()
        if self.persons.count > 0
        {
            self.addPersonToElevator()
        }
        else
        {
            if self.addMostPersonToEmptyElevator() == false
            {
                self.elevatorState = .EMPTY_MOVE
                self.elevatorAction()
            }
        }
        self.addPersonsToFloor()
    }
    
    func emptyMoveAction()
    {
        let needFloor = self.building?.getNerbyPersonFloor(self.currentFloor)
        if needFloor > self.currentFloor
        {
            self.direction = .UP
            self.checkForPersonsInBuilding(.UP)
            self.elevatorState = .MOVE_UP
        }
        else
        {
            self.direction = .DOWN
            self.checkForPersonsInBuilding(.DOWN)
            self.elevatorState = .MOVE_DOWN
        }
    }

    //MARK: Cheking
    
    func checkForPersonsInBuilding(direction:Direction)
    {
        if self.building?.havePersonsOnFloors() == true
        {
            self.direction = direction
        }
        else
        {
            self.moveTimer.invalidate()
        }
    }
    
    func askAction()
    {
        if self.needToStopOnFloor(self.currentFloor)
        {
            self.elevatorState = .STOP
            self.elevatorAction()
            return
        }
        if self.persons.count == Constants.maxPersonInElevator
        {
            return;
        }
        let currentFloor = self.currentFloor
        self.building?.needToStopOnFloor(currentFloor, direction: self.direction) {[weak weakSelf = self] answer in
            if(answer || weakSelf?.persons.count == 0)
            {
                weakSelf?.elevatorState = .STOP
                self.elevatorAction()
            }
        }
    }
    
    func needToStopOnFloor(floorNumber:Int) -> Bool
    {
        for person in self.persons
        {
            if person.destinationFloor == floorNumber
            {
                return true;
            }
        }
        return false;
    }
    
    //MARK: Managing persons in elevetor and floor

    func addPersonToElevator()
    {
        let needToAdd = Constants.maxPersonInElevator - self.persons.count
        let personsOnFloor = (self.building?.getPersons(self.currentFloor, direction: self.direction,personCount: needToAdd))!
        if personsOnFloor.count != 0
        {
            self.persons.appendContentsOf(personsOnFloor)
        }
        
        self.elevatorState = self.direction == .UP ? .MOVE_UP : .MOVE_DOWN
    }
    
    func addMostPersonToEmptyElevator() -> Bool
    {
        let mostPersons = self.building?.getMostPersons(self.currentFloor)
        if mostPersons!.persons.count > 0
        {
            self.persons = mostPersons!.persons
            self.direction = mostPersons!.direction
            self.elevatorState = self.direction == .UP ? .MOVE_UP : .MOVE_DOWN
            return true;
        }
        return false
    }
    
    func removePersonInNeededFloor()
    {
        for (index,person) in self.persons.enumerate().reverse() {
            if person.destinationFloor == self.currentFloor
            {
                self.outPersons.append(person)
                persons.removeAtIndex(index)
            }
        }
    }
    func addPersonsToFloor()
    {
        for (index,person) in self.outPersons.enumerate().reverse()
        {
            self.building?.addPersonToFloorAndRegenerateDestFloor(self.currentFloor, person: person)
            self.outPersons.removeAtIndex(index)
        }
    }
}

extension Elevator:PrintSelf
{
    func printSelf() -> String {
        var elevatorDescription =  "Elevator: floor - \(self.currentFloor), direction - \(self.direction)\n"
        for person in self.persons
        {
            elevatorDescription = "\(elevatorDescription)\(person.printSelf())"
        }
        return elevatorDescription
    }
}
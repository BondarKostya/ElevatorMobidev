//
//  Elevator.swift
//  ElevatorMobidev
//
//  Created by Admin on 12.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

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
    weak var building:Building?
    var moveTimer:NSTimer!
    var currentFloor = 1
    var maxFloor:Int!
    var maxPersonCount = 5
    var peoples = [Person]()
    var elevatorState = ElevatorState.STOP {
        didSet {
            if oldValue == .MOVE_UP || oldValue == .MOVE_DOWN
            {
                self.elevatorAction()
            }
        }
    }
    var direction = Direction.UP
    init(maxFloor:Int,building:Building) {
        super.init()
        self.building = building
        self.maxFloor = maxFloor
        elevatorState = .STOP
        self.startOrResumeTimer()
    }
    
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
    
    func emptyMoveAction()
    {
        
        let needFloor = self.building?.getNerbyPersonFloor(self.currentFloor)
        if needFloor > self.currentFloor
        {
            self.direction = .UP
            self.checkForPeoplesInBuilding(.UP)
            self.elevatorState = .MOVE_UP
        }
        else
        {
            self.direction = .DOWN
            self.checkForPeoplesInBuilding(.DOWN)
            self.elevatorState = .MOVE_DOWN
        }
    }
    
    func moveUpAction()
    {
        if self.currentFloor != self.maxFloor
        {
            self.askAction()
            self.direction = .UP
            self.currentFloor = self.currentFloor + 1
        }else
        {
            self.stopAction()
            self.checkForPeoplesInBuilding(.DOWN)
        }
    }
    
    func checkForPeoplesInBuilding(direction:Direction)
    {
        if self.building?.havePeoplesOnFloors() == true
        {
            self.direction = direction
        }
        else
        {
            self.moveTimer.invalidate()
        }
    }
    
    func moveDownAction()
    {
        if self.currentFloor > 1
        {
            self.askAction()
            self.direction = .DOWN
            self.currentFloor = self.currentFloor - 1
        }else
        {
            self.stopAction()
            self.checkForPeoplesInBuilding(.UP)
        }
    }
    
    func stopAction()
    {
        self.removePeopleInNeededFloor()
        if self.peoples.count > 0
        {
            self.addPeopleToElevator()
        }
        else
        {
            if self.addMostPeopleToEmptyElevator() == false
            {
                self.elevatorState = .EMPTY_MOVE
            }
        }
    }
    
    func addPeopleToElevator()
    {
        let needToAdd = 5 - self.peoples.count
        let peopleOnFloor = (self.building?.getPeople(self.currentFloor, direction: self.direction,personCount: needToAdd))!
        self.peoples.appendContentsOf(peopleOnFloor)
        self.elevatorState = self.direction == .UP ? .MOVE_UP : .MOVE_DOWN
    }
    
    func addMostPeopleToEmptyElevator() -> Bool
    {
        let mostPeople = self.building?.getMostPeople(self.currentFloor)
        if mostPeople!.peoples.count > 0
        {
            self.peoples = mostPeople!.peoples
            self.direction = mostPeople!.direction
            self.elevatorState = self.direction == .UP ? .MOVE_UP : .MOVE_DOWN
            return true;
        }
        return false
    }
    
    func removePeopleInNeededFloor()
    {
        for (index,person) in self.peoples.enumerate().reverse() {
            if person.destinationFloor == self.currentFloor
            {
                peoples.removeAtIndex(index)
            }
        }
    }
    
    func checkForUtmostFloor() -> Bool
    {
        if(self.currentFloor == 1 || self.currentFloor == self.maxFloor)
        {
            if(self.currentFloor == 1)
            {
                self.peoples = (self.building?.getPeople(self.currentFloor, direction: .UP,personCount: 5))!
                self.direction = .UP
                self.elevatorState = .MOVE_UP
                self.checkForPeoplesInBuilding(.DOWN)
            }else
            {
                self.peoples = (self.building?.getPeople(self.currentFloor, direction: .DOWN,personCount: 5))!
                self.direction = .DOWN
                self.elevatorState = .MOVE_DOWN
            }
            return true
        }
        return false
    }
    
    func askAction()
    {
        if(self.peoples.count == 0)
        {
            let upCheck = self.building?.getPeople(self.currentFloor, direction: .UP, personCount: 5);
            if upCheck?.count > 0
            {
                self.peoples = upCheck!
            }else
            {
                let downCheck = self.building?.getPeople(self.currentFloor, direction: .UP, personCount: 5);
                if(downCheck?.count > 0)
                {
                    self.peoples = downCheck!
                }
                
            }
        }
        if self.needToStopOnFloor(self.currentFloor)
        {
            self.elevatorState = .STOP
            return
        }
        if self.peoples.count == 5
        {
            return;
        }
        let currentFloor = self.currentFloor
        self.building?.needToStopOnFloor(currentFloor, direction: self.direction) {[weak weakSelf = self] answer in
            if(answer)
            {
                weakSelf?.elevatorState = .STOP
            }
        }
    }
    
    func needToStopOnFloor(floorNumber:Int) -> Bool
    {
        for person in self.peoples
        {
            if person.destinationFloor == floorNumber
            {
                return true;
            }
        }
        return false;
    }
    
    @objc func needToMove() {
        
        elevatorAction()
        
        ConsoleWrapper.rePrintConsole()
    }
    
    func startOrResumeTimer()
    {
        moveTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(Elevator.needToMove), userInfo: nil, repeats: true)
    }
}

extension Elevator:PrintSelf
{
    func printSelf() -> String {
        var elevatorDescription =  "Elevator: floor - \(self.currentFloor), direction - \(self.direction)\n"
        for person in self.peoples
        {
            elevatorDescription = "\(elevatorDescription)\(person.printSelf())"
        }
        return elevatorDescription
    }
}
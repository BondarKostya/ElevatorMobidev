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
    var peoples = [Person]()
    var elevatorState = ElevatorState.STOP {
        didSet {
            //switching moveUp to moveDown always pass through the stop state
            if oldValue == .MOVE_UP || oldValue == .MOVE_DOWN
            {
                self.elevatorAction()
            }
        }
    }
    
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

    //MARK: Cheking
    
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
    
    func askAction()
    {
        if self.needToStopOnFloor(self.currentFloor)
        {
            self.elevatorState = .STOP
            return
        }
        if self.peoples.count == Constants.maxPersonInElevator
        {
            return;
        }
        let currentFloor = self.currentFloor
        self.building?.needToStopOnFloor(currentFloor, direction: self.direction) {[weak weakSelf = self] answer in
            if(answer || weakSelf?.peoples.count == 0)
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
    
    //MARK: Managing persons in elevetor and floor

    func addPeopleToElevator()
    {
        let needToAdd = Constants.maxPersonInElevator - self.peoples.count
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
//
//  ConsoleWrapper.swift
//  ElevatorMobidev
//
//  Created by Admin on 12.09.16.
//  Copyright © 2016 bondar.k.dev. All rights reserved.
//

import Foundation

class ConsoleWrapper:NSObject
{
    static let objectsForPrint = NSMutableArray();
    
    static func rePrintConsole()
    {
        clearConsole();
        printObjectsToConsole();
    }
    
    static func printObjectsToConsole()
    {
        for object in objectsForPrint
        {
            if let printObject = object as? PrintSelf
            {
                print("\(printObject.printSelf())\n")
            }
        }
    }
    //I haven't found way to clear console through code
    static func clearConsole()
    {
        for _ in 0...Constants.consoleWhiteSpace
        {
            print("\n")
        }
    }
    
}
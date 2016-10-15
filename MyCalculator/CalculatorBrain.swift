//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by Andrew Huber on 10/4/16.
//  Copyright © 2016 Andrew Huber. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // ------------------------------------------------------------------------------------
    // CONSTANTS
    // ------------------------------------------------------------------------------------
    
    /** The + symbol (the addition symbol) */
    static let plusSign = "+"
    
    /** The - symbol (the subtraction symbol) */
    static let minusSign = "–"
    
    /** The × symbol (the multiplication symbol) */
    static let multiplicationSign = "×"
    
    /** The ÷ symbol (the divison symbol) */
    static let divisionSign = "÷"
    
    /** The decimal point "." */
    static let point = "."
    
    /** The clear button text ("AC") that appears on the calculator */
    static let ac = "AC"
    
    /** 
        The "+/–" symbol on the calculator that makes a number negative when positive,
        and positive when negative.
    */
    static let plusMinus = "\(CalculatorBrain.plusSign)/\(CalculatorBrain.minusSign)"
    
    /** The percent sign ("%") */
    static let percentSign = "%"
    
    // ------------------------------------------------------------------------------------
    // END OF CONSTANTS
    // ------------------------------------------------------------------------------------
    
    /** 
     An enum that is a child of Error which contains all the possible errors that can be 
     thrown in CalculatorBrain.
     */
    enum CalculatorBrainError: Error {
        /** Used whenever an invalid parameter is passed into a method. */
        case InvalidParameter(invalidParameter: AnyObject, withMessage: String?)
        
        /** Used whenever the CalculatorBrain is in an invalid state */
        case InvalidState(message: String)
    }
    
    // ------------------------------------------------------------------------------------
    // START OF CalculatorState
    // ------------------------------------------------------------------------------------
    
    // Stores state of calculator
    private struct CalculatorState {
        
        // Used to determine the value in the CalculatorState that is currently being or should be edited
        enum Value {
            case FirstNumber(withStringOf: String?, andDoubleOf: Double?)
            case SecondNumber(withStringOf: String?, andDoubleOf: Double?)
            case EvaluatedNumber(withDoubleOf: Double?)
        }
        
        var firstNumberAsString: String?
        var secondNumberAsString: String?
        var binaryOperation: ((Double, Double) -> Double)?
        var evaluatedNumber: Double?
        
        /*
            A computed property that, at any given moment, converts firstNumberAsString
            as a Double (get) OR converts a Double to a String and stores it back into
            firstNumberAsString
        */
        var firstNumberAsDouble: Double? {
            get {
                if let first = firstNumberAsString {
                    return Double(first)
                }
                else {
                    return nil
                }
            }
            set {
                if let value = newValue {
                    firstNumberAsString = String(value)
                }
                else {
                    firstNumberAsString = nil
                }
            }
        }
        
        /*
         A computed property that, at any given moment, converts firstNumberAsString
         as a Double (get) OR converts a Double to a String and stores it back into
         firstNumberAsString
         */
        var secondNumberAsDouble: Double? {
            get {
                if let second = secondNumberAsString {
                    return Double(second)
                }
                else {
                    return nil
                }
            }
            set {
                if let value = newValue {
                    secondNumberAsString = String(value)
                }
                else {
                    secondNumberAsString = nil
                }
            }
        }
        
        /** Returns the current value being edited or the value that should be edited */
        var currentValue: Value {
            if self.evaluatedNumber != nil {
                return .EvaluatedNumber(withDoubleOf: self.evaluatedNumber)
            }
            else if self.binaryOperation != nil {
                return .SecondNumber(withStringOf: self.secondNumberAsString, andDoubleOf: self.secondNumberAsDouble)
            }
            else {
                return .FirstNumber(withStringOf: self.firstNumberAsString, andDoubleOf: self.firstNumberAsDouble)
            }
        }
        
        /** "Unraps" currentValue by extracting the String? and Double? from the enums. This is a tuple containing currentValue, and the unrwapped String? and Double? from currentValue */
        var unwrappedCurrentValue: (Value, String?, Double?) {
            let value = currentValue
            switch value {
            case .FirstNumber(let stringValue, let doubleValue): return (value, stringValue, doubleValue)
            case .SecondNumber(let stringValue, let doubleValue): return (value, stringValue, doubleValue)
            case .EvaluatedNumber(let doubleValue): return (value, nil, doubleValue)
            }
        }
        
        /**
         Sets a particular value in the CalculatorState
         
         - Parameters:
            - value:    The value that is to be set
            - to:       The value that `value` should be set to
        */
        mutating func setValue(value: Value, to newValue: AnyObject) throws {
            switch value {
            case .FirstNumber:
                if let newVal = newValue as? String {
                    self.firstNumberAsString = newVal
                }
                else if let newVal = newValue as? Double {
                    self.firstNumberAsDouble = newVal
                }
                else {
                    var message = "\(CalculatorBrain.CalculatorState.Value.FirstNumber) requires a Double or a String, but it is of "
                    
                    if let type = newValue.type {
                        message += "type \(type)"
                    }
                    else {
                        message += "unknown type"
                    }
                    
                    throw CalculatorBrainError.InvalidParameter(invalidParameter: newValue, withMessage: message)
                }
            case .SecondNumber:
                if let newVal = newValue as? String {
                    self.secondNumberAsString = newVal
                }
                else if let newVal = newValue as? Double {
                    self.secondNumberAsDouble = newVal
                }
                else {
                    var message = "\(CalculatorBrain.CalculatorState.Value.SecondNumber) requires a Double or a String, but it is of "
                    
                    if let type = newValue.type {
                        message += "type \(type)"
                    }
                    else {
                        message += "unknown type"
                    }
                }
                
            case .EvaluatedNumber:
                if let newVal = newValue as? Double {
                    self.evaluatedNumber = newVal
                }
                else {
                    var message = "\(CalculatorBrain.CalculatorState.Value.EvaluatedNumber) requires a Double, but it is of "
                    
                    if let type = newValue.type {
                        message += type
                    }
                    else {
                        message += "unknown type"
                    }
                }
            }
        }
        
        /* 
            Sets binaryOperation, firstNumberAsString, secondNumberAsString, and 
            evaluatedNumber to nil, effectively "clearing out" this CalculatorState
        */
        mutating func clear() {
            self.binaryOperation = nil
            self.firstNumberAsString = nil
            self.secondNumberAsString = nil
            self.evaluatedNumber = nil
        }
    }
    
    // ------------------------------------------------------------------------------------
    // END OF CalculatorState
    // ------------------------------------------------------------------------------------
    
    // This calculator state
    private var state = CalculatorState()
    
    /** 
     Retrieves the contents that the calculator's display should display
     
     - Returns: the contents that the calculator's display should display
     */
    func getDisplayContents() throws -> String {
        let (_, stringValue, doubleValue) = state.unwrappedCurrentValue
        
        if let string = stringValue {
            return string
        }
        else if let double = doubleValue {
            // If evaluated number can be represented as an Int,
            // then convert it to an Int and return the Int as a
            // String
            if floor(double) == double {
                return String(Int(double))
            }
                
                // Otherwise, return evaluatedNumber as a String w/o
                // conversion to Int
            else {
                return String(double)
            }
        }
        else {
            throw CalculatorBrainError.InvalidState(message: "Encountered an invalid state when calling displayContent's getter")
        }
    }
    
    /**
     Whenever the controller wishes to give the brain a digit or decimal point (i.e.,
     whenever a digit button OR the "." is pressed), this method should be called.
     
     - Parameter digitOrDecimalPoint: The text on the button
    */
    func giveDigitOrDecimalPoint(_ digitOrDecimalPoint: String) throws {
        
        let validParams = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "." ]
        
        if !validParams.contains(digitOrDecimalPoint) {
            throw CalculatorBrainError.InvalidParameter(invalidParameter: digitOrDecimalPoint as AnyObject, withMessage: nil)
        }
        
        if state.evaluatedNumber != nil {
            state.clear()
        }
        
        let (value, stringValue, _) = state.unwrappedCurrentValue
        
        if let string = stringValue {
            try state.setValue(value: value, to: (string + digitOrDecimalPoint) as AnyObject)
        }
        else {
            try state.setValue(value: value, to: digitOrDecimalPoint as AnyObject)
        }
    }
    
    /**
     Whenever the controller wishes to give the brain a unary operator (thus far, this
     is only "+/–" and "%"), this method should be called. Throws 
     CalculatorBrainError.invalidParameter(parameterFound: String) if an unsupported 
     operator is given.
     
     - Parameter op: The operator
    */
    func giveUnaryOperator(_ op: String) throws {
        
        let (value, stringValue, doubleValue) = state.unwrappedCurrentValue
        
        // if operator is +/-
        if op == CalculatorBrain.plusMinus {
            
            if let string = stringValue {
                if firstCharacterOfString(string) == CalculatorBrain.minusSign {
                    try state.setValue(value: value, to: removeFirstCharacterFromString(string) as AnyObject)
                }
                else {
                    try state.setValue(value: value, to: (CalculatorBrain.minusSign + string) as AnyObject)
                }
            }
            else if let double = doubleValue {
                try state.setValue(value: value, to: (double * -1.0) as AnyObject)
            }
        }
            
        // if the operator is %
        else if op == CalculatorBrain.percentSign {
            if let double = doubleValue {
                try state.setValue(value: value, to: (double / 100.0) as AnyObject)
            } else {
                throw CalculatorBrainError.InvalidState(message: "There is no double value stored in \(value)")
            }
        }
        
        else {
            throw CalculatorBrainError.InvalidParameter(invalidParameter: op as AnyObject, withMessage: nil)
        }
    }
    
    /**
     Whenever the controller wishes to give the brain a binary operator (thus far, this
     is only "+", "–", "×", and "÷"), this method should be called. Throws
     CalculatorBrainError.invalidParameter(paremeterFound: String) if an unsupported
     operator is given.
     
     - Parameter op: The operator
    */
    func giveBinaryOperator(_ op: String) throws {
        
        if state.secondNumberAsString != nil {
            evaluate()
        }
        
        if state.evaluatedNumber != nil{
            try prepareForNewCalculation()
        }
        
        switch op {
        case CalculatorBrain.plusSign: state.binaryOperation = { $0 + $1 }
        case CalculatorBrain.minusSign: state.binaryOperation = { $0 - $1 }
        case CalculatorBrain.multiplicationSign: state.binaryOperation = { $0 * $1 }
        case CalculatorBrain.divisionSign: state.binaryOperation = { $0 / $1 }
        default: throw CalculatorBrainError.InvalidParameter(invalidParameter: op as AnyObject, withMessage: nil)
        }
    }
    
    /**
     Performs the operation on the first and second number so long as they both were
     provided and a bianary operator was also provided. If one or more of these are 
     missing, then nothing is done.
    */
    func evaluate() {
        if let first = state.firstNumberAsDouble {
            if let second = state.secondNumberAsDouble {
                if let operation = state.binaryOperation {
                    state.evaluatedNumber = operation(first, second)
                }
            }
        }
    }
    
    /* Clears the state of the calculator */
    func clear() {
        state.clear()
    }
    
    // Returns the first character of a String
    private func firstCharacterOfString(_ string: String) -> String {
        return String(string[string.startIndex])
    }
    
    // Removes the first character of a string. This is used to remove the negative
    // sign from a string that contains a negative number.
    //
    // Returns the string without the first character
    private func removeFirstCharacterFromString(_ string: String) -> String {
        return string.substring(from: string.index(after: string.startIndex))
    }
    
    // Clears out state, but sets state's firstNumberAsString to the CURRENT 
    // displayContents
    private func prepareForNewCalculation() throws {
        let oldDisplayContents = try getDisplayContents()
        state.clear()
        state.firstNumberAsString = oldDisplayContents
    }
}

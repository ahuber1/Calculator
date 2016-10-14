//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by Andrew Huber on 10/4/16.
//  Copyright © 2016 andrewhuber. All rights reserved.
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
    
    /** The default text that the calculator should display. This is by default "0" */
    static var defaultDisplayText = "0"
    
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
        case InvalidParameter(invalidParameter: String)
    }
    
    // Stores state of calculator
    private struct CalculatorState {
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
    
    // This calculator state
    private var state = CalculatorState()
    
    /** A get-only property that returns what the calculator display should display */
    var displayContents: String {
        /* 
            This if-else block follows the following pattern:
         
                1) If evaluatedNumber does not equal nil (i.e., if the first and second
                   number have been evaluated), then that is the number that should be
                   displayed, so return it.
         
                2) Otherwise, if secondNumber does not equal nil (i.e., if the user has
                   entered or is entering the second number), then that is the number that
                   should be displayed, so return it.
         
                3) Otherwise, if firstNumber does not equal nil (i.e., if the user has
                   entered or is intering the first number), then that is the number that
                   should be displayed, so return it.
         
                4) Otherwise, the default text (CalculatorBrain.defaultDisplayText) should 
                   be displayed.
         */
        if let evaluatedNumber = state.evaluatedNumber {
            // If evaluated number can be represented as an Int,
            // then convert it to an Int and return the Int as a
            // String
            if floor(evaluatedNumber) == evaluatedNumber {
                return String(Int(evaluatedNumber))
            }
                
            // Otherwise, return evaluatedNumber as a String w/o
            // conversion to Int
            else {
                return String(evaluatedNumber)
            }
        }
        if let second = state.secondNumberAsString {
            return second
        }
        else if let first = state.firstNumberAsString {
            return first
        }
        else {
            return CalculatorBrain.defaultDisplayText
        }
    }
    
    /**
     Whenever the controller wishes to give the brain a digit or decimal point (i.e.,
     whenever a digit button OR the "." is pressed), this method should be called.
     
     - Parameter digitOrDecimalPoint: The text on the button
    */
    func giveDigitOrDecimalPoint(_ digitOrDecimalPoint: String) {
        
        if state.evaluatedNumber != nil {
            prepareForNewCalculation()
            
            // Undo part of what was done in prepareForNewCalculation() (explanation below)
            state.firstNumberAsString = nil
            
            /*
             EXPLANATION: prepareForNewCalculation() sets all of the variables in state
             to nil except for firstNumberAsString, which is set to what was originally
             in evaluatedNumber BEFORE all the variables in state are set to nil. This
             needs to be done because if giveDigit(digit: String) is called (i.e., if
             0–9 or the "." button is pressed) and state.evaluatedNumber is nil, this
             can only be the case because the user pressed the "AC" button, which means
             that we need to clear out state.firstNumberAsString so the user can set the
             first number.
            */
        }
        
        // If there is no binary operation, then the first number should be set
        if state.binaryOperation == nil {
            // The first button the user pressed is not ".", set the display to what the user entered.
            if state.firstNumberAsString == nil && digitOrDecimalPoint != CalculatorBrain.point {
                state.firstNumberAsString = "0."
            }
            // If the user began to edit the number
            else if let first = state.firstNumberAsString {
                state.firstNumberAsString = first + digitOrDecimalPoint
            }
            // If the user entered "."
            else {
                state.firstNumberAsString = digitOrDecimalPoint
            }
        }
        // If there is a binary operation, then the second number should be set
        else {
            // The first button the user pressed is not ".", set the display to what the user entered.
            if state.secondNumberAsString == nil && digitOrDecimalPoint != CalculatorBrain.point {
                state.secondNumberAsString = digitOrDecimalPoint
            }
            // If the user began to edit the number
            else if let second = state.secondNumberAsString {
                state.secondNumberAsString = second + digitOrDecimalPoint
            }
            // If the user entered "."
            else {
                state.secondNumberAsString = digitOrDecimalPoint
            }
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
        
        // if operator is +/-
        if op == CalculatorBrain.plusMinus {
            if let second = state.secondNumberAsString {
                if firstCharacterOfString(second) == CalculatorBrain.minusSign {
                    state.secondNumberAsString = removeFirstCharacterFromString(second)
                }
                else {
                    state.secondNumberAsString = CalculatorBrain.minusSign + second
                }
            }
            else if let first = state.firstNumberAsString {
                if firstCharacterOfString(first) == CalculatorBrain.minusSign {
                    state.firstNumberAsString = removeFirstCharacterFromString(first)
                }
                else {
                    state.firstNumberAsString = CalculatorBrain.minusSign + first
                }
            }
        }
            
        // if the operator is %
        else if op == CalculatorBrain.percentSign {
            if let evaluated = state.evaluatedNumber {
                state.evaluatedNumber = evaluated / 100.0
            }
            else if let second = state.secondNumberAsDouble {
                state.secondNumberAsDouble = second / 100.0
            }
            else if let first = state.firstNumberAsDouble {
                state.firstNumberAsDouble = first / 100.0
            }
        }
        
        else {
            throw CalculatorBrainError.InvalidParameter(invalidParameter: op)
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
            prepareForNewCalculation()
        }
        
        switch op {
        case CalculatorBrain.plusSign: state.binaryOperation = { $0 + $1 }
        case CalculatorBrain.minusSign: state.binaryOperation = { $0 - $1 }
        case CalculatorBrain.multiplicationSign: state.binaryOperation = { $0 * $1 }
        case CalculatorBrain.divisionSign: state.binaryOperation = { $0 / $1 }
        default: throw CalculatorBrainError.InvalidParameter(invalidParameter: op)
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
    private func prepareForNewCalculation() {
        let oldDisplayContents = displayContents
        state.clear()
        state.firstNumberAsString = oldDisplayContents
    }
}

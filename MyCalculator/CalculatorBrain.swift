//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by Andrew Huber on 10/4/16.
//  Copyright © 2016 andrewhuber. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    // Text found on buttons except for digits
    static let plusSign = "+"
    static let minusSign = "–"
    static let multiplicationSign = "×"
    static let divisionSign = "÷"
    static let point = "."
    static let ac = "AC"
    static let plusMinus = "\(CalculatorBrain.plusSign)/\(CalculatorBrain.minusSign)"
    static let percentSign = "%"
    
    // Stores state of calculator
    private struct CalculatorState {
        var firstNumberAsString: String?
        var secondNumberAsString: String?
        var binaryOperation: ((Double, Double) -> Double)?
        var evaluatedNumber: Double?
        
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
            }
        }
        
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
            }
        }
        
        mutating func clear() {
            self.binaryOperation = nil
            self.firstNumberAsString = nil
            self.secondNumberAsString = nil
            self.evaluatedNumber = nil
        }
    }
    
    // The calculator state
    private var state = CalculatorState()
    
    // What the calculator should display
    var displayContents: String {
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
            return "0"
        }
    }
    
    func giveDigit(digit: String) {
        
        if state.evaluatedNumber != nil {
            prepareForNewCalculation()
            state.firstNumberAsString = nil // undo part of what was done in prepareForNewCalculation()
        }
        
        if state.binaryOperation == nil {
            if state.firstNumberAsString == nil && digit != CalculatorBrain.point {
                state.firstNumberAsString = digit
            }
            else if let first = state.firstNumberAsString {
                state.firstNumberAsString = first + digit
            }
            else {
                state.firstNumberAsString = digit // will this execute?
            }
        }
        else {
            if state.secondNumberAsString == nil && digit != CalculatorBrain.point {
                state.secondNumberAsString = digit
            }
            else if let second = state.secondNumberAsString {
                state.secondNumberAsString = second + digit
            }
            else {
                state.secondNumberAsString = digit // will this execute?
            }
        }
    }
    
    func giveUnaryOperator(op: String) {
        
        // if operator is +/-
        if op == CalculatorBrain.plusMinus {
            
            if let second = state.secondNumberAsString {
                if firstCharacterOfString(second) == CalculatorBrain.minusSign {
                    state.secondNumberAsString = removeMinusSignFromString(second)
                }
                else {
                    state.secondNumberAsString = CalculatorBrain.minusSign + second
                }
            }
            else if let first = state.firstNumberAsString {
                if firstCharacterOfString(first) == CalculatorBrain.minusSign {
                    state.firstNumberAsString = removeMinusSignFromString(first)
                }
                else {
                    state.firstNumberAsString = CalculatorBrain.minusSign + first
                }
            }
        }
            
        // if the operator is %
        else {
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
    }
    
    func giveBinaryOperator(op: String) {
        
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
        default: state.binaryOperation = { $0 / $1 }
        }
    }
    
    func evaluate() {
        if let first = state.firstNumberAsDouble {
            if let second = state.secondNumberAsDouble {
                if let operation = state.binaryOperation {
                    state.evaluatedNumber = operation(first, second)
                }
            }
        }
    }
    
    func clear() {
        state.clear()
    }
    
    private func firstCharacterOfString(_ string: String) -> String {
        return String(string[string.startIndex])
    }
    
    private func removeMinusSignFromString(_ string: String) -> String {
        return string.substring(from: string.index(after: string.startIndex))
    }
    
    private func prepareForNewCalculation() {
        let oldDisplayContents = displayContents
        state.clear()
        state.firstNumberAsString = oldDisplayContents
    }
}

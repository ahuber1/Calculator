//
//  ViewController.swift
//  MyCalculator
//
//  Created by Andrew Huber on 10/3/16.
//  Copyright © 2016 andrewhuber. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // The CalculatorBrain object (the model in our MVC)
    private let brain = CalculatorBrain()
    
    /**  The calculator's display.*/
    @IBOutlet weak var calculatorDisplay: UILabel!
    
    /** 
        Called whenever the user presses a button with a digit or decimal point on it.
        
        - Parameter sender: The UIButton that the user pressed.
    */
    @IBAction func digitOrDecimalPointPressed(_ sender: UIButton) {
        do {
            try brain.giveDigitOrDecimalPoint(sender.titleLabel!.text!)
            calculatorDisplay.text = try brain.getDisplayContents()
        } catch {
            handleError(error, sender: "digitOrDecimalPointPressed(UIButton)")
        }
    }
    
    /** 
        Called whenever the user presses a button for a binary operator. Currently,
        those buttons are "+", "–", "×", and "÷".
     
        - Parameter sender: The UIButton that the user pressed.
    */
    @IBAction func binaryOperatorPressed(_ sender: UIButton) {
        do {
            try brain.giveBinaryOperator(sender.titleLabel!.text!)
            calculatorDisplay.text = try brain.getDisplayContents()
        } catch {
            handleError(error, sender: "binaryOperatorPressed(UIButton)")
        }
    }
    
    /**
        Called whenever the user presses a button for a unary operator. Currently, 
        those buttons are "+/–" and "%".
     
        - Parameter sender: The UIButton that the user pressed.
    */
    @IBAction func unaryOperatorPressed(_ sender: UIButton) {
        do {
            try brain.giveUnaryOperator(sender.titleLabel!.text!)
            calculatorDisplay.text = try brain.getDisplayContents()
        } catch {
            handleError(error, sender: "unaryOperatorPressed(UIButton)")
        }
    }
    
    /**
        Called whenever the user presses the "AC" button on the calculator.
        
        - Parameter sender: The UIButton that was pressed (the "AC" button)
    */
    @IBAction func clearPressed(_ sender: UIButton) {
        do {
            brain.clear()
            calculatorDisplay.text = try brain.getDisplayContents()
        } catch {
            handleError(error, sender: "clearPressed(UIButton)")
        }
    }
    
    /**
        Called whenever the user presses the "=" button on the calculator.
        
        - Parameter sender: The UIButton that was pressed (the "=" button)
    */
    @IBAction func equalsPressed(_ sender: UIButton) {
        do {
            brain.evaluate()
            calculatorDisplay.text = try brain.getDisplayContents()
        } catch {
            handleError(error, sender: "equalsPressed(UIButton)")
        }
    }
    
    // Handles errors
    private func handleError(_ error: Error, sender: String) {
        if let calculatorBrainError = error as? CalculatorBrain.CalculatorBrainError {
            switch calculatorBrainError {
            case .InvalidState(let message):
                print(message)
            case .InvalidParameter(let param, let message):
                if let msg = message {
                    print(msg)
                } else {
                    print("Invalid parameter of \(param) when \(sender) was called")
                }
            }
        }
        else {
            print(error.localizedDescription)
        }
    }
}

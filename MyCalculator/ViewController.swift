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
        brain.giveDigitOrDecimalPoint(sender.titleLabel!.text!)
        calculatorDisplay.text = brain.displayContents
    }
    
    /** 
        Called whenever the user presses a button for a binary operator. Currently,
        those buttons are "+", "–", "×", and "÷".
     
        - Parameter sender: The UIButton that the user pressed.
    */
    @IBAction func binaryOperatorPressed(_ sender: UIButton) {
        do {
            try brain.giveBinaryOperator(sender.titleLabel!.text!)
            calculatorDisplay.text = brain.displayContents
        } catch CalculatorBrain.CalculatorBrainError.InvalidParameter(let param) {
            print("Invalid parameter sent to giveBinaryOperator(String) of \"\(param)\"")
        } catch {
            print("Exception of unkown type was thrown by giveBinaryOperator(String)")
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
            calculatorDisplay.text = brain.displayContents
        } catch CalculatorBrain.CalculatorBrainError.InvalidParameter(let param) {
            print("Invalid parameter sent to giveUnaryOperator(String) of \"\(param)\"")
        } catch {
            print("Exception of unknown type was thrown by giveUnaryOperator(String)")
        }
    }
    
    /**
        Called whenever the user presses the "AC" button on the calculator.
        
        - Parameter sender: The UIButton that was pressed (the "AC" button)
    */
    @IBAction func clearPressed(_ sender: UIButton) {
        brain.clear()
        calculatorDisplay.text = brain.displayContents
    }
    
    /**
        Called whenever the user presses the "=" button on the calculator.
        
        - Parameter sender: The UIButton that was pressed (the "=" button)
    */
    @IBAction func equalsPressed(_ sender: UIButton) {
        brain.evaluate()
        calculatorDisplay.text = brain.displayContents
    }
}

//
//  ViewController.swift
//  MyCalculator
//
//  Created by Andrew Huber on 10/3/16.
//  Copyright © 2016 andrewhuber. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let brain = CalculatorBrain()
    
    @IBOutlet weak var calculatorLabel: UILabel!
    
    @IBAction func digitPressed(_ sender: UIButton) {
        brain.giveDigit(digit: sender.titleLabel!.text!)
        calculatorLabel.text = brain.displayContents
    }
    
    @IBAction func binaryOperatorPressed(_ sender: UIButton) {
        brain.giveBinaryOperator(op: sender.titleLabel!.text!)
        calculatorLabel.text = brain.displayContents
    }
    
    @IBAction func unaryOperatorPressed(_ sender: UIButton) {
        brain.giveUnaryOperator(op: sender.titleLabel!.text!)
        calculatorLabel.text = brain.displayContents
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        brain.clear()
        calculatorLabel.text = brain.displayContents
    }
    
    @IBAction func equalsPressed(_ sender: UIButton) {
        brain.evaluate()
        calculatorLabel.text = brain.displayContents
    }
}

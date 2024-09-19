//
//  ViewController.swift
//  KeychainKit Test
//
//  Created by Dominic Rodemer on 19.09.24.
//

import UIKit
import KeychainKit

class ViewController: UIViewController {
    
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var stringTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func writeButtonAction(_ sender: Any?) {
        
        if let numberString = numberTextField.text {
            if let number = Int(numberString) {
                Keychain.default.set(number, forKey: "my.number.key")
            }
        }
        
        if let string = stringTextField.text {
            Keychain.default.set(string, forKey: "my.string.key")
        }
    }
    
    @IBAction func readButtonAction(_ sender: Any?) {
        
        if let number = Keychain.default.object(of: Int.self, forKey: "my.number.key") {
            numberTextField.text = String(format: "%d", number)
        } else {
            numberTextField.text = nil
        }

        stringTextField.text = Keychain.default.string(forKey: "my.string.key")
    }
    
    @IBAction func removeButtonAction (_ sender: Any?) {
        Keychain.default.removeObject(forKey: "my.number.key")
        numberTextField.text = nil
        
        Keychain.default.removeObject(forKey: "my.string.key")
        stringTextField.text = nil
    }
}


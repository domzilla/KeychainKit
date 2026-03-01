//
//  ViewController.swift
//  KeychainKit Test
//
//  Created by Dominic Rodemer on 19.09.24.
//

import KeychainKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var stringTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction
    func writeButtonAction(_: Any?) {
        var dict: [String: String] = [:]

        if let numberString = numberTextField.text {
            if let number = Int(numberString) {
                Keychain.default.set(number, forKey: "my.number.key")
                dict["number"] = numberString
            }
        }

        if let string = stringTextField.text {
            Keychain.default.set(string, forKey: "my.string.key")
            dict["string"] = string
        }

        Keychain.default.set(dict, forKey: "my.dict.key")
    }

    @IBAction
    func readButtonAction(_: Any?) {
        if let number = Keychain.default.object(of: Int.self, forKey: "my.number.key") {
            self.numberTextField.text = String(format: "%d", number)
        } else {
            self.numberTextField.text = nil
        }

        self.stringTextField.text = Keychain.default.string(forKey: "my.string.key")

        if let dict = Keychain.default.object(of: [String: String].self, forKey: "my.dict.key") {
            print(dict)
        }
    }

    @IBAction
    func removeButtonAction(_: Any?) {
        Keychain.default.removeObject(forKey: "my.number.key")
        self.numberTextField.text = nil

        Keychain.default.removeObject(forKey: "my.string.key")
        self.stringTextField.text = nil

        Keychain.default.removeObject(forKey: "my.dict.key")
    }
}

//
//  NewExerciseController+UIPickerView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/3/22.
//

import Foundation
import UIKit

extension NewExerciseController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categories[row] == " " {
            showError(title: "Error", message: "Please select a category!")
        } else {
            categorySelectorTextField.text = categories[row]
            categorySelectorTextField.resignFirstResponder()
        }
    }
    
    
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
}

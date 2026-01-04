//
//  PickerView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/2/26.
//
import UIKit

extension LinkedExercisesController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableCategoriesToLink.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableCategoriesToLink[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        linkCategorySelectorTextField.text = availableCategoriesToLink[row]
        linkCategorySelectorTextField.resignFirstResponder()
    }
}

//
//  HomeController+UIPickerView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/3/22.
//

import UIKit

extension HomeController {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return catsNameOnly.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return catsNameOnly[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        workoutPickerValueChanged(workout: catsNameOnly[row])
        UserDefaults.standard.setValue(catsNameOnly[row], forKey: "selectedCategory")
        print("row = ", row)
        activeSegment = row
        workoutCategorySelectorTextField.text = catsNameOnly[row]
        workoutCategorySelectorTextField.resignFirstResponder()
    }
    
    

}

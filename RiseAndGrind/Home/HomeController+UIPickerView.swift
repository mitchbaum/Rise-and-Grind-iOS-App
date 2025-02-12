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
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.setValue(categories[row], forKey: "selectedCategory")
        activeSegment = row
        workoutCategorySelectorTextField.text = categories[row]
        workoutCategorySelectorTextField.resignFirstResponder()
        navigationItem.leftBarButtonItems = populateBarBtnItems(side: "left")
        fetchExercises()
    }
    
    

}

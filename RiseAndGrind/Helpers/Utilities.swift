//
//  Utilities.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/4/21.
//

import Foundation
import UIKit
import SwiftUI
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
extension String
{
    func image(fontSize:CGFloat = 40, bgColor:UIColor = UIColor.clear, imageSize:CGSize? = nil) -> UIImage?
    {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let imageSize = imageSize ?? self.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        bgColor.set()
        let rect = CGRect(origin: .zero, size: imageSize)
        UIRectFill(rect)
        self.draw(in: rect, withAttributes: [.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension Date {
    func timeAgoDisplay() -> String {

        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date())!
        let yearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!

        if minuteAgo < self {
//            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "Updated just now"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "Updated \(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            if diff == 1 {
                return "Updated \(diff) hr ago"
            } else {
                return "Updated \(diff) hrs ago"
            }
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            if diff == 1 {
                return "Updated \(diff) day ago"
            } else {
                return "Updated \(diff) days ago"
            }
        } else if threeMonthsAgo < self {
            let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
            if diff == 1 {
                return "Updated \(diff) week ago"
            } else {
                return "Updated \(diff) weeks ago"
            }
        } else if yearAgo < self {
            let diff = Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
            
            if diff == 1 {
                return "Updated \(diff) month ago"
            } else {
                return "Updated \(diff) months ago"
            }
        }
        let diff = Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
        if diff == 1 {
            return "Updated \(diff) year ago"
        } else {
            return "Updated \(diff) years ago"
        }
    }
    
}

// this extension adds padding ability to textfield placeholder text
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

enum LinePosition {
    case top
    case bottom
}

extension UIView {
    func addLine(position: LinePosition, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .top:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .bottom:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
}

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get { return self.value(forKey: "titleTextColor") as? UIColor }
        set { self.setValue(newValue, forKey: "titleTextColor") }
    }
}
extension Double {
    func toFixed(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UINavigationBar {

    func makeContent(color: UIColor) {
        let attributes: [NSAttributedString.Key: Any]? = [.foregroundColor: color]

        self.titleTextAttributes = attributes
        self.topItem?.leftBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        self.topItem?.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    }
}
class Utilities {
    static func timestampToFormattedDate(timeStamp: String, monthAbbrev: String) -> String {
        let timeStampString = timeStamp
        let timeStampDouble = Double(timeStampString) ?? 0.0
        let date = Date(timeIntervalSince1970: timeStampDouble)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "\(monthAbbrev) d, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    // takes a date November 18, 2024 returns the timestamp 1692340012.967895
    static func convertDateToTimestamp(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy" // Match the format of your input date string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing

        if let date = dateFormatter.date(from: dateString) {
            let timestamp = date.timeIntervalSince1970
            return String(timestamp)
        } else {
            return nil // Return nil if the date string couldn't be parsed
        }
    }
    static func timestampConversion(timeStamp: String) -> Date {
        // handle time stamp
        // convert firebase timestamp variable from Unic Epoch to date
        let myTimeInterval = TimeInterval(timeStamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval ?? 0.0))
        // change date type back to string
        let timeString = "\(time)"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        // format the string
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = dateFormatter.date(from:timeString)!
        return date
    }
    
    
    // animation for the "Show Summary" button
    static func animateView(_ viewToAnimate: UIView) {
        UIView.animate(withDuration: 0.10, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.6, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.10, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    // Minimum 6 characters
    /*
     ^                         Start anchor
     (?=.*[A-Z].*[A-Z])        Ensure string has two uppercase letters.
     (?=.*[!@#$&*])            Ensure string has one special case letter.
     (?=.*[0-9].*[0-9])        Ensure string has two digits.
     (?=.*[a-z].*[a-z].*[a-z]) Ensure string has three lowercase letters.
     .{8}                      Ensure string is of length 8.
     $                         End anchor.
     */
     
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^.{6,}$")
        return passwordTest.evaluate(with: password)
    }
    
    // checks the user entered email is valid
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func setThemeColor(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let components: [CGFloat] = [red, green, blue, alpha]
            print(components)
            UserDefaults.standard.setValue(components, forKey: "theme")
        }
    }
    
    static func loadTheme() -> UIColor {
        guard let array = UserDefaults.standard.object(forKey: "theme") as? [CGFloat], array.count == 4 else { return UIColor.lightBlue }
        let color = UIColor(red: array[0], green: array[1], blue: array[2], alpha: array[3])
        
        return color
    }
    
    static func loadThemeSwiftUI() -> Color {
        guard let array = UserDefaults.standard.object(forKey: "theme") as? [CGFloat], array.count == 4 else {
            return Color.blue // Default fallback
        }
        let color = UIColor(red: array[0], green: array[1], blue: array[2], alpha: array[3])
        // Convert UIColor to SwiftUI Color
        return Color(color)
    }
    
    static func loadAppearanceTheme(property: String, optionalMode: String? = nil) -> UIColor {
        let mode = optionalMode ?? (UserDefaults.standard.object(forKey: "appearanceTheme") as? String ?? "Light")
        if property == "primaryCell" || property == "primary"{
            return mode == "Light" ? UIColor.white : UIColor.dimGray
        } else if property == "primaryTopCell" {
            return mode == "Light" ? UIColor.offWhite : UIColor.offDimGray
        } else if property == "secondary" {
            return mode == "Light" ? UIColor.darkGray : UIColor.black
        } else if property == "text" {
            return mode == "Light" ? UIColor.black : UIColor.white
        } else if property == "accent" {
            return self.loadTheme()
        }
        
        
        guard let array = UserDefaults.standard.object(forKey: "theme") as? [CGFloat], array.count == 4 else { return UIColor.lightBlue }
        let color = UIColor(red: array[0], green: array[1], blue: array[2], alpha: array[3])
        
        return color
    }
    
    
}

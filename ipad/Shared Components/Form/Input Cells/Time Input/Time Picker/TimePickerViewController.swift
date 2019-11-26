//
//  TimePickerViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

public struct Time {
    var hour: Int
    var minute: Int
    var seconds: Int
    
    init(hour: Int, minute: Int, seconds: Int) {
        self.hour = hour
        self.minute = minute
        self.seconds = seconds
    }
    
    init(string: String) {
        let timeArray = string.components(separatedBy: ":")
        self.hour = Int(timeArray[0]) ?? 0
        self.minute = Int(timeArray[1]) ?? 0
        self.seconds = 0
    }
    
    func toString() -> String {
        var displayMinute: String = ""
        if minute < 10 {
            displayMinute = "0\(minute)"
        } else {
            displayMinute = "\(minute)"
        }
        return "\(hour):\(displayMinute)"
    }
}

public class TimePickerViewController: UIViewController {
    
    var onChange: ((_ time: Time)-> Void)?
    
    @IBOutlet weak var pickerView: UIDatePicker!
    
    
    func setup(initial: Time?, onChange: @escaping(_ time: Time?) -> Void) {
        if initial != nil {
            print("TIME PICKER DOES NOT SUPPORT INITIAL TIME BEING SET")
        }
        self.onChange = onChange
    }
    
    @IBAction func onTimeChange(_ sender: UIDatePicker) {
        guard let callback = onChange else {return}
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sender.date)
        let minutes = calendar.component(.minute, from: sender.date)
        let seconds = calendar.component(.second, from: sender.date)
        return callback(Time(hour: hour, minute: minutes, seconds: seconds))
    }
    
}

//
//  DatePickerViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/9/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

protocol DatePickerDelegate {
    func datePicker(_ picker: DatePickerViewController, didFinishWithDate date: Date?, withTimeInterval interval: TimeInterval?)
}

class DatePickerViewController: UIViewController {
    
    var delegate: DatePickerDelegate?
    
    var date: Date? {
        didSet {
            if date == nil {
                isTimeSet = false
            } else {
                datePicker?.setDate(date!, animated: true)
            }
            updateUI()
        }
    }
    
    var timeInterval: TimeInterval? {
        get {
            if date != nil {
                if isTimeSet {
                    let calendar = Calendar.current
                    let component = calendar.dateComponents( [.hour, .minute, .second], from: self.date!)
                    
                    return component.timeInterval
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    var isTimeSet: Bool = false
    
    private var pickerMode: UIDatePickerMode {
        return datePicker.datePickerMode
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if date == nil {
            buttonDate?.setTitle("Add a Date", for: .normal)
            buttonDate?.tintColor = UIColor.disabledState
            datePicker?.isUserInteractionEnabled = false
            datePicker?.alpha = UIColor.disabledStateOpacity
        } else {
            buttonDate?.setTitle(DateFormatter.localizedString(from: date!, dateStyle: .medium, timeStyle: .none), for: .normal)
            buttonDate?.tintColor = UIColor.defaultButtonTint
            datePicker?.isUserInteractionEnabled = true
            datePicker?.alpha = 1
        }
        
        if timeInterval == nil {
            buttonTime?.setTitle("Time", for: .normal)
            buttonTime?.tintColor = UIColor.disabledState
        } else {
            buttonTime?.setTitle(DateFormatter.localizedString(from: date!, dateStyle: .none, timeStyle: .short), for: .normal)
            buttonTime?.tintColor = UIColor.defaultButtonTint
        }
        
        updateBarButtons()
    }
    
    private func updateBarButtons() {
        if barButtons == nil || datePicker == nil {
            return
        }
        for button in barButtons {
            if pickerMode == .date {
                if button.tag == 1 {
                    button.title = "Today"
                } else if button.tag == 2 {
                    button.title = "Tomorrow"
                } else if button.tag == 3 {
                    button.title = DateComponents(date: Date().addingTimeInterval(CTDateComponentDay*2), forComponents: [.weekday]).weekdayTitle!
                }
            } else if pickerMode == .time {
                if button.tag == 1 {
                    button.title = "9:00am"
                } else if button.tag == 2 {
                    button.title = "12:00pm"
                } else if button.tag == 3 {
                    button.title = "3:00pm"
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonDate: UIButton!
    @IBAction func pressDate(_ sender: Any) {
        datePicker.datePickerMode = .date
        if date == nil {
            date = Date()
        } else {
            updateBarButtons()
        }
    }
    
    @IBOutlet weak var buttonTime: UIButton!
    @IBAction func pressTime(_ sender: Any) {
        datePicker.datePickerMode = .time
        isTimeSet = true
        if date == nil {
            date = Date()
        }
        updateUI()
    }
    
    @IBOutlet weak var datePicker: UIDatePicker! { didSet { datePicker.setDate(date ?? Date(), animated: true) } }
    @IBAction func didChangeDatePicker(_ sender: Any) {
        switch datePicker.datePickerMode {
        case .date:
            date = datePicker.date
        case .time:
            isTimeSet = true
            date = datePicker.date
        default:
            break
        }
    }
    
    @IBOutlet private var barButtons: [UIBarButtonItem]!
    @IBAction func pressToolbarButton(_ sender: UIBarButtonItem) {
        if pickerMode == .date {
            func dateWithOffset(_ offset: TimeInterval) -> Date {
                var _date = DateComponents(date: (date ?? Date()), forComponents: [.hour, .minute])
                let todaysDate = DateComponents(date: Date(timeIntervalSinceNow: offset), forComponents: [.day, .month, .year])
                _date.day = todaysDate.day
                _date.month = todaysDate.month
                _date.year = todaysDate.year
                
                return Calendar.current.date(from: _date)!
            }
            if sender.tag == 1 {
                date = dateWithOffset(0)
            } else if sender.tag == 2 {
                date = dateWithOffset(CTDateComponentDay)
            } else if sender.tag == 3 {
                date = dateWithOffset(CTDateComponentDay*2)
            } else if sender.tag == 4 {
                date = nil
            }
        } else if pickerMode == .time {
            func dateWithInterval(_ offset: TimeInterval) -> Date {
                var _date = DateComponents(date: date!, forComponents: [.day, .month, .year])
                _date.hour = 0
                _date.minute = 0
                
                isTimeSet = true
                
                return Calendar.current.date(from: _date)!.addingTimeInterval(offset)
            }
            if sender.tag == 1 {
                date = dateWithInterval(CTDateComponentHour*9)
            } else if sender.tag == 2 {
                date = dateWithInterval(CTDateComponentHour*12)
            } else if sender.tag == 3 {
                date = dateWithInterval(CTDateComponentHour*15)
            } else if sender.tag == 4 {
                isTimeSet = false
                updateUI()
            }
        }
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self!.delegate?.datePicker(self!, didFinishWithDate: self!.date, withTimeInterval: self!.timeInterval)
        }
        
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        updateUI()
    }
}

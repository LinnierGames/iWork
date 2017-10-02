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

struct DatePickerOptions {
    var canSetDate: Bool
    var dateRequired: Bool
    var datePresets: [TimeInterval]
    var dateRanges: Range<Date>?
    var timeRanges: Bool
    
    var canSetTime: Bool
    var timeRequired: Bool
    var timePresets: [TimeInterval]
    
    var pickerMode: UIDatePickerMode
    
    var tag: Int8?
    
    init() {
        canSetDate = true
        canSetTime = true
        dateRequired = true
        timeRequired = true
        datePresets = [0,CTDateComponentDay,CTDateComponentDay*2] //Today, Tomorrow and Day After Tomorrow
        timePresets = [CTDateComponentHour*9,CTDateComponentHour*14,CTDateComponentHour*17] //9a, 2p and 5p
        timeRanges = false
        pickerMode = .date //TODO: Display days of the week in the date picker
    }
}

class DatePickerViewController: UIViewController {
    
    var options = DatePickerOptions()
    
    var date: Date? {
        didSet {
            if date == nil {
                isTimeSet = false
            } else {
                datePicker?.setDate(date!, animated: true)
                //TODO: validate the date against min and max ranges
            }
            updateUI()
        }
    }
    
    private var timeInterval: TimeInterval? {
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
    
    private var pickerMode: UIDatePickerMode? {
        return datePicker?.datePickerMode
    }
    
    var delegate: DatePickerDelegate?
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if date == nil {
            buttonDate?.setTitle("Add a Date", for: .normal)
            buttonDate?.tintColor = UIColor.disabledState
            datePicker?.isUserInteractionEnabled = false
            datePicker?.alpha = UIColor.disabledStateOpacity
        } else {
            buttonDate?.setTitle(String(date!, dateStyle: .medium), for: .normal)
            buttonDate?.tintColor = UIColor.defaultButtonTint
            if pickerMode == .time, isTimeSet == false {
                datePicker?.isUserInteractionEnabled = false
                datePicker?.alpha = UIColor.disabledStateOpacity
            } else {
                datePicker?.isUserInteractionEnabled = true
                datePicker?.alpha = 1
            }
        }
        
        if timeInterval == nil {
            buttonTime?.setTitle("Time", for: .normal)
            buttonTime?.tintColor = UIColor.disabledState
        } else {
            buttonTime?.setTitle(String(date!, dateStyle: .none, timeStyle: .short), for: .normal)
            buttonTime?.tintColor = UIColor.defaultButtonTint
        }
        
        updateBarButtons()
    }
    
    //TODO: validate date mins/maxs so the presets don't get added if out of range
    private func updateBarButtons() {
        if barButtons == nil || datePicker == nil {
            return
        }
        
        if pickerMode == .date {
            var buttonTag = 0
            self.toolbarItems!.removeAll()
            let todaysDay = DateComponents(date: Date(), forComponents: [.weekday])
            let tomorrowsDay = DateComponents(date: Date(timeIntervalSinceNow: CTDateComponentDay), forComponents: [.weekday])
            for preset in options.datePresets {
                var presetComponent = DateComponents(date: Date(timeIntervalSinceNow: preset), forComponents: [.weekday])
                presetComponent.calendar = Calendar.current
                let buttonTitle: String
                if presetComponent == todaysDay {
                    buttonTitle = "Today"
                } else if presetComponent == tomorrowsDay {
                    buttonTitle = "Tomorrow"
                } else {
                    buttonTitle = presetComponent.weekdayTitle!
                }
                let barButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(pressToolbarButton(_:)))
                barButton.tag = buttonTag
                self.toolbarItems!.append(barButton)
                
                let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                self.toolbarItems!.append(spacer)
                if preset == options.datePresets.last! {
                    if options.dateRequired == false {
                        let noneBarButton = UIBarButtonItem(title: "None", style: .plain, target: self, action: #selector(pressToolbarButton(_:)))
                        noneBarButton.tag = -1
                        self.toolbarItems!.append(noneBarButton)
                    }
                    break
                }
                buttonTag += 1
            }
        } else if pickerMode == .time {
            var buttonTag = 0
            self.toolbarItems!.removeAll()
            for preset in options.timePresets {
                let buttonTitle = String(Date(timeIntervalSinceToday: preset), dateStyle: .none, timeStyle: .short)
                let barButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(pressToolbarButton(_:)))
                barButton.tag = buttonTag
                self.toolbarItems!.append(barButton)
                
                let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                self.toolbarItems!.append(spacer)
                if preset == options.timePresets.last! {
                    if options.timeRequired == false {
                        let noneBarButton = UIBarButtonItem(title: "None", style: .plain, target: self, action: #selector(pressToolbarButton(_:)))
                        noneBarButton.tag = -1
                        self.toolbarItems!.append(noneBarButton)
                    }
                    break
                }
                buttonTag += 1
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonDate: UIButton! {
        didSet {
            buttonDate.isHidden = options.canSetDate.inverse
        }
    }
    @IBAction private func pressDate(_ sender: Any) {
        datePicker.datePickerMode = .date
        if date == nil {
            date = Date()
        } else {
            updateUI()
        }
    }
    
    @IBOutlet weak var buttonTime: UIButton! {
        didSet {
            buttonTime.isHidden = options.canSetTime.inverse
        }
    }
    @IBAction private func pressTime(_ sender: Any) {
        datePicker.datePickerMode = .time
        isTimeSet = true
        if date == nil {
            date = Date()
        }
        updateUI()
    }
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.datePickerMode = options.pickerMode
            if options.dateRanges != nil {
                if options.timeRanges == false {
                    var minDate = DateComponents(date: options.dateRanges!.lowerBound, forComponents: [.year,.month,.day,.hour,.minute,.second])
                    minDate.hour = 0
                    minDate.minute = 0
                    minDate.second = 0
                    var maxDate = DateComponents(date: options.dateRanges!.upperBound, forComponents: [.year,.month,.day,.hour,.minute,.second])
                    maxDate.hour = 23
                    maxDate.minute = 59
                    maxDate.second = 59
                    options.dateRanges = Range<Date>(uncheckedBounds: (lower: minDate.dateValue!, upper: maxDate.dateValue!))
                }
                datePicker.maximumDate = options.dateRanges!.upperBound
                datePicker.minimumDate = options.dateRanges!.lowerBound
            }
            datePicker.setDate(date ?? Date(), animated: false)
        }
    }
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
    
    @IBOutlet private var barButtons: [UIBarButtonItem]! {
        didSet {
            
        }
    }
    @IBAction func pressToolbarButton(_ sender: UIBarButtonItem) {
        if pickerMode == .date {
            /// Returns the date from the time interval
            /// Day, month and year are only effected
            func dateWithOffset(_ offset: TimeInterval) -> Date {
                var _date = DateComponents(date: (date ?? Date()), forComponents: [.hour, .minute])
                let todaysDate = DateComponents(date: Date(timeIntervalSinceNow: offset), forComponents: [.day, .month, .year])
                _date.day = todaysDate.day
                _date.month = todaysDate.month
                _date.year = todaysDate.year
                
                return Calendar.current.date(from: _date)!
            }
            if sender.tag != -1 {
                date = dateWithOffset(options.datePresets[sender.tag])
            } else {
                date = nil
            }
        } else if pickerMode == .time {
            /// Returns the date from the time interval from midnight
            /// Hour and minut are only effected
            func dateWithInterval(_ offset: TimeInterval) -> Date {
                var _date = DateComponents(date: date!, forComponents: [.day, .month, .year])
                _date.hour = 0
                _date.minute = 0
                
                isTimeSet = true
                
                return Calendar.current.date(from: _date)!.addingTimeInterval(offset)
            }
            if sender.tag != -1 {
                date = dateWithInterval(options.timePresets[sender.tag])
            } else {
                isTimeSet = false
                updateUI()
            }
        }
    }
    
    @IBAction private func pressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.datePicker(self, didFinishWithDate: self.date, withTimeInterval: self.timeInterval)
        
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        updateUI()
    }
}


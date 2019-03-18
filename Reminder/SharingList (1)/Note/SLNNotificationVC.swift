//
//  SLNNotificationVC.swift
//  Reminder
//
//  Created by Yijia Huang on 10/1/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit
import UserNotifications

/// notification view controller
class SLNNotificationVC: ReminderStandardViewController {
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        setNotifications()
        
    }

    /// set notifications
    @objc func setNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if granted {
                print("notification access granted")
            } else {
                print(error?.localizedDescription ?? "err")
            }
        })
    }
    
    /// notification button
    ///
    /// - Parameter sender: sender data
    @IBAction func notifyButton(_ sender: UIButton) {
        scheduleNotification(inSeconds: 5, completion: { success in
            if success {
                print("Successfully scheduled notfication")
            } else {
                print("err")
            }
        })
    }
    
    /// schedule notification
    ///
    /// - Parameters:
    ///   - inSeconds: time interval
    ///   - completion: completion
    @objc func scheduleNotification(inSeconds: TimeInterval, completion: @escaping (_ success: Bool) -> ()) {
        let notif = UNMutableNotificationContent()
        
        notif.title = "New Notification"
        notif.subtitle = "These are great!"
        notif.body = "The new notification options in iOS 10 are what I've always dreamed of!"
        
        let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: "mynotif", content: notif, trigger: notifTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print(error ?? "err")
            completion(false)
            } else {
            completion(true)
            }
        })
    }

}

//
//  ReminderDateFormatter.swift
//  Reminder
//
//  Created by Jason on 2017/10/13.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation

class ReminderDateFormatter: DateFormatter {
    
    override init() {
        super.init()
        self.dateStyle = .medium
        self.timeStyle = .none
        self.locale=Locale(identifier: "en_US")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

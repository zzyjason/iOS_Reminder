//
//  DouobleExtension.swift
//  Reminder
//
//  Created by Jason on 2017/9/17.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation


extension Double{
    
    func toInt() -> Int?
    {
        if (self != self.rounded()){
            return nil
        }
        return Int(self.rounded())

    }
}

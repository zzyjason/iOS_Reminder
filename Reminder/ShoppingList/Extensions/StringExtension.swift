//
//  StringExtension.swift
//  Reminder
//
//  Created by Jason on 2017/10/26.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation

extension String{
    var numbers:Int
    {

        let Result=String(characters.filter({"0"..."9" ~= $0}))


        return Int(Result) ?? -1
    }
}

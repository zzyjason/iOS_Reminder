//
//  DesignableView.swift
//  Reminder
//
//  Created by Jason on 2017/10/1.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit

/// Class that programmer can use it to make changes to the view on story board
@IBDesignable class DesignableView: UIView {

    /// Enable Change the Boarder Color on story board
    @IBInspectable var BoarderColor:UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor=BoarderColor.cgColor
        }
    }
    
    /// Enable Change the corener Radius on story board
    @IBInspectable var CornerRadius:CGFloat=0{
        didSet{
            self.layer.cornerRadius=CornerRadius
        }
    }
    
    /// Enable Change the border Width on story board
    @IBInspectable var BorderWidth:CGFloat=0{
        didSet{
            self.layer.borderWidth=BorderWidth
        }
    }
    

}

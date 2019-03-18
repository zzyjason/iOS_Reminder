//
//  CustomTransitioning.swift
//  Reminder
//
//  Created by Jason on 2017/11/4.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation

class MenuTransitioning:NSObject,UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate  {
    

    

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let FromViewController=transitionContext.viewController(forKey: .from),let ToViewController=transitionContext.viewController(forKey: .to) else {
            return
        }
        UIApplication.shared.keyWindow!.addSubview(ToViewController.view)
        
        ToViewController.view.transform = CGAffineTransform(translationX: -260, y: 0)
        
   //     FromViewController.view.frame=CGRect(x: 0, y: 0, width: FromViewController.view.frame.width/, height: FromViewController.view.frame.height/2)
        FromViewController.view.transform=CGAffineTransform(a: 1.0, b: 0, c: 0, d: 1.0, tx: -260, ty: 0)//CGAffineTransform(translationX: -260, y: 0)
        
        FromViewController.view.center=CGPoint(x:447.5,y:333.5)
        

        
        UIView.animate(withDuration: transitionDuration(using: nil), delay: 0, options:.curveLinear, animations: {
            FromViewController.view.transform=CGAffineTransform.identity
            ToViewController.view.transform = CGAffineTransform.identity
            
        }) { (success) in

            transitionContext.completeTransition(true)
            if(UIApplication.shared.keyWindow!.subviews.count != 2 ){
            
                UIApplication.shared.keyWindow!.subviews[1].removeFromSuperview()
            }
            
        }
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return MenuTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return DismissTransitioning()
    }
    
}

class NewFeatureTransitioning:NSObject,UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate {
    
    
    
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let FromViewController=transitionContext.viewController(forKey: .from),let ToViewController=transitionContext.viewController(forKey: .to) else {
            print("Something Wrong")
            return
        }
        
        
        UIApplication.shared.keyWindow!.addSubview(ToViewController.view)
        
        FromViewController.view.transform=CGAffineTransform(translationX: 260, y: 0)
        ToViewController.view.transform = CGAffineTransform(translationX: 260, y: 0)
        
        FromViewController.view.center=CGPoint(x: -72.5, y: 333.5)

        

        ToViewController.view.center=CGPoint(x: 187.5, y: 333.5)
        
        UIView.animate(withDuration: transitionDuration(using: nil), delay: 0, options:.curveLinear, animations: {
            FromViewController.view.transform=CGAffineTransform.identity
            ToViewController.view.transform = CGAffineTransform.identity
            
        }) { (success) in
            
            transitionContext.completeTransition(true)
            
            if(UIApplication.shared.keyWindow!.subviews.count != 2 ){
                
                UIApplication.shared.keyWindow!.subviews[1].removeFromSuperview()
            }
            
            UIApplication.shared.keyWindow!.subviews[0].removeFromSuperview()
            
            
        }
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return NewFeatureTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return DismissTransitioning()
        
    }
    
    
}

class DismissTransitioning:NSObject,UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let FromViewController=transitionContext.viewController(forKey: .from),let ToViewController=transitionContext.viewController(forKey: .to) else {
            return
        }

        FromViewController.view.transform=CGAffineTransform(translationX: 260, y: 0)
        ToViewController.view.transform = CGAffineTransform(translationX: 260, y: 0)
        ToViewController.view.center=CGPoint(x: 187.5, y: 333.5)
        FromViewController.view.center=CGPoint(x: -72.5, y: 333.5)
        
        UIView.animate(withDuration: transitionDuration(using: nil), delay: 0, options:.curveLinear, animations: {
            FromViewController.view.transform=CGAffineTransform.identity
            ToViewController.view.transform = CGAffineTransform.identity

        }) { (success) in
            
            transitionContext.completeTransition(true)
        }
        
    }
    
    
    
}

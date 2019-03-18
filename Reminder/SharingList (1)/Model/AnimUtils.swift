//
//  AnimUtils.swift
//  AppleProducts
//
//  Created by Yijia Huang on 9/18/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit

/// animtion 
class AnimUtils: NSObject, UITabBarControllerDelegate {
    // MARK: - Methods
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScrollingTransitionAnimator(tabBarController: tabBarController,
                                           lastIndex: tabBarController.selectedIndex)
    }
}

/// scrolling transition animator
class ScrollingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Variables
    @objc weak var transitionContext: UIViewControllerContextTransitioning?
    @objc var tabBarController: UITabBarController!
    @objc var lastIndex = 0
    
    // MARK: - Methods
    
    /// Asks your animator object for the duration (in seconds) of the transition animation.
    ///
    /// - Parameter transitionContext: transition context
    /// - Returns: time interval
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    
    /// initialize controller
    ///
    /// - Parameters:
    ///   - tabBarController: tab bar controller
    ///   - lastIndex: last index
    @objc init(tabBarController: UITabBarController, lastIndex: Int) {
        self.tabBarController = tabBarController
        self.lastIndex = lastIndex
    }
    
    
    /// Tells your animator object to perform the transition animations.
    ///
    /// - Parameter transitionContext: transition context
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        containerView.addSubview(toViewController!.view)
        
        var viewWidth = toViewController!.view.bounds.width
        
        if tabBarController.selectedIndex < lastIndex {
            viewWidth = -viewWidth
        }
        
        toViewController!.view.transform = CGAffineTransform(translationX: viewWidth, y: 0)
        
        UIView.animate(withDuration: self.transitionDuration(using: (self.transitionContext)), delay: 0.0, usingSpringWithDamping: 1.2, initialSpringVelocity: 2.5, options: .overrideInheritedOptions, animations: {
            toViewController!.view.transform = CGAffineTransform.identity
            fromViewController!.view.transform = CGAffineTransform(translationX: -viewWidth, y: 0)
        }, completion: { _ in
            self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
            fromViewController!.view.transform = CGAffineTransform.identity
        })
    }
}

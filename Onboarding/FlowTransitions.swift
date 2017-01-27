//
//  FlowTransitions.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/25/17.
//

import Foundation
import UIKit

protocol TransitionableFlowViewController
{
    var viewsToFade: [UIView] { get }
    var viewsToSlide: [UIView] { get }
}

class FlowAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
         return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let toViewController = transitionContext.viewController(forKey: .to)! as! TransitionableFlowViewController
        let fromViewController = transitionContext.viewController(forKey: .from)! as! TransitionableFlowViewController
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        let containerView = transitionContext.containerView
        
        let travelDistance = containerView.bounds.size.width
        
        for viewToSlideIn in toViewController.viewsToSlide
        {
            viewToSlideIn.transform = CGAffineTransform(translationX: travelDistance, y: 0)
        }
        
        for viewToFadeIn in toViewController.viewsToFade
        {
            viewToFadeIn.alpha = 0
        }
        
        let oldBackgroundColor = toView.backgroundColor
        toView.backgroundColor = UIColor.clear
        containerView.addSubview(toView)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations:
        {
            for viewToSlideIn in toViewController.viewsToSlide
            {
                viewToSlideIn.transform = CGAffineTransform.identity
            }
            for viewToSlideOut in fromViewController.viewsToSlide
            {
                viewToSlideOut.transform = CGAffineTransform(translationX: -travelDistance, y: 0)
            }
            
            for viewToFadeIn in toViewController.viewsToFade
            {
                viewToFadeIn.alpha = 1
            }
            
            for viewToFadeOut in fromViewController.viewsToFade
            {
                viewToFadeOut.alpha = 0
            }
        })
        { (finished) in
            toView.backgroundColor = oldBackgroundColor
            if transitionContext.transitionWasCancelled
            {
                toView.removeFromSuperview()
            }
            else
            {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

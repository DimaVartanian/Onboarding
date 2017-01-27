//
//  FlowDirector.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/24/17.
//

import Foundation
import UIKit

class FlowDirector: NSObject, UINavigationControllerDelegate
{
    let flowScreens: [FlowScreen]
    var flowAnimator: FlowAnimator?
    
    init(withFlow flowScreens:[FlowScreen])
    {
        self.flowScreens = flowScreens
        super.init()
    }
    
    var answers = [String: Any]() // Answer Identifier: Value
    var currentScreenIndex = 0
    
    lazy var navigationController: UINavigationController =
    {
        let firstFlowScreen = self.createViewControllerForFlowScreen(flowScreen: self.flowScreens[self.currentScreenIndex], pastAnswers: self.answers)
        let navController = UINavigationController(rootViewController: firstFlowScreen)
        navController.delegate = self
        navController.setNavigationBarHidden(true, animated: false)
        return navController
    }()
    
    func createViewControllerForFlowScreen(flowScreen: FlowScreen, pastAnswers: [String: Any]) -> FlowScreenViewController
    {
        let viewModel = FlowScreenViewModel(withFlow: flowScreen, pastAnswers: pastAnswers)
        {
            answers in
            self.advance(withAnswers: answers)
        }
        let viewController = FlowScreenViewController(withViewModel: viewModel)
        return viewController
    }
    
    func advance(withAnswers newAnswers: [String: Any])
    {
        for (key, value) in newAnswers
        {
            answers[key] = value
        }
        
        var nextScreenIndex = currentScreenIndex + 1
        var nextScreen: FlowScreen?
        var areConditionsMet = false
        while nextScreenIndex < flowScreens.count
        {
            let screenToCheck = flowScreens[nextScreenIndex]
            areConditionsMet = ConditionEvaluator.areConditionsMet(conditionGroup: screenToCheck.requiredCondition, pastAnswers: answers)
            if areConditionsMet
            {
                nextScreen = screenToCheck
                break
            }
            else
            {
                nextScreenIndex += 1
            }
        }
        if let nextScreen = nextScreen
        {
            currentScreenIndex = nextScreenIndex
            let nextFlowViewController = createViewControllerForFlowScreen(flowScreen: nextScreen, pastAnswers: answers)
            self.navigationController.pushViewController(nextFlowViewController, animated: true)
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if fromVC is TransitionableFlowViewController && toVC is TransitionableFlowViewController
        {
            return FlowAnimator()
        }
        return nil
    }
}

//
//  FlowScreenViewModel.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/24/17.
//

import Foundation

class FlowScreenViewModel: NSObject
{
    // Input
    let screen: FlowScreen
    let pastAnswers: [String: Any]
    
    init(withFlow flowScreen: FlowScreen, pastAnswers: [String: Any], completionHandler: @escaping ([String: Any]) -> Void)
    {
        self.screen = flowScreen
        self.pastAnswers = pastAnswers
        self.completionHandler = completionHandler
    }
    
    
    var formattedHeader: String
    {
        get
        {
            return screen.header.formattedText(referenceAnswers: pastAnswers)
        }
    }
    
    var formattedTakeaways: [String]?
    {
        get
        {
            return screen.takeaways?.map { $0.formattedText(referenceAnswers: pastAnswers) }
        }
    }
    
    var formattedQuestions: [String]?
    {
        get
        {
            return screen.inputs?.map { $0.question.formattedText(referenceAnswers: pastAnswers) }
        }
    }
    
    var inputs: [Input]?
    {
        get
        {
            return screen.inputs
        }
    }
    
    func acceptAnswers(answers: [String]) -> Bool
    {
        for (index, answer) in answers.enumerated()
        {
            if answer.isEmpty
            {
                return false
            }
            let input = inputs![index]
            if input.answerParameters.type == .int
            {
                if let intAnswer = Int(answer)
                {
                    self.answers[input.identifier] = intAnswer
                }
                else
                {
                    return false
                }
            }
            else
            {
                self.answers[input.identifier] = answer
            }
        }
        completionHandler(self.answers)
        return true
    }
    
    // Output
    let completionHandler: ([String: Any]) -> Void
    var answers = [String: Any]() // Answer Identifier: Value
}

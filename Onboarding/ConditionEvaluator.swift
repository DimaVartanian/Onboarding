//
//  ConditionEvaluator.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/25/17.
//

import Foundation

struct ConditionEvaluator
{
    static func areConditionsMet(conditionGroup: ConditionGroup?, pastAnswers answers: [String: Any]) -> Bool
    {
        guard let conditionGroup = conditionGroup
        else
        {
            return true
        }
        
        var conditionResults = [Bool]()
        
        if let conditions = conditionGroup.conditions
        {
            for condition in conditions
            {
                conditionResults.append(isConditionMet(condition: condition, pastAnswers: answers))
            }
        }
        else
        {
            for nestedGroup in conditionGroup.conditionGroups!
            {
                conditionResults.append(areConditionsMet(conditionGroup: nestedGroup, pastAnswers: answers))
            }
        }
        return doResultsSatisfyFunction(results: conditionResults, function: conditionGroup.function)
    }
    
    private static func isConditionMet(condition: Condition, pastAnswers answers:[String: Any]) -> Bool
    {
        let pastAnswer = answers[condition.answerIdentifier]
        
        switch condition.comparisonType
        {
        case .equalTo:
            if let pastAnswerInt = pastAnswer as? Int, let comparisonValueInt = condition.comparisonValue as? Int
            {
                return pastAnswerInt == comparisonValueInt
            }
            else
            {
                let pastAnswerString = pastAnswer as! String
                let comparisonValueString = condition.comparisonValue as! String
                return pastAnswerString == comparisonValueString
            }
        case .lessThan:
            let pastAnswerInt = pastAnswer as! Int
            let comparisonValueInt = condition.comparisonValue as! Int
            return pastAnswerInt < comparisonValueInt
        case .greaterThan:
            let pastAnswerInt = pastAnswer as! Int
            let comparisonValueInt = condition.comparisonValue as! Int
            return pastAnswerInt > comparisonValueInt
        }
    }
    
    private static func doResultsSatisfyFunction(results: [Bool], function: ConditionFunctionType) -> Bool
    {
        switch function
        {
            case .AND:
                return !results.contains(false)
            case .OR:
                return results.contains(true)
            case .NOT:
                return !results.contains(true)
        }
    }
}

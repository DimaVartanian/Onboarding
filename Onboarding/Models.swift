//
//  Models.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/24/17.
//

import Foundation

// MARK: - Formatted text

struct TextWithFormat
{
    let text: String
    let formatSpecifiers: [FormatSpecifier]?
    
    init(withJSON JSON:[String: Any])
    {
        text = JSON["text"] as! String
        if let formatJSON = JSON["format_specifiers"] as? [[String: Any]]
        {
            var formatSpecifiers = [FormatSpecifier]()
            for currentFormatJSON in formatJSON
            {
                let currentFormat = FormatSpecifier(withJSON: currentFormatJSON)
                formatSpecifiers.append(currentFormat)
            }
            self.formatSpecifiers = formatSpecifiers
        }
        else
        {
            formatSpecifiers = nil
        }
    }
    
    func formattedText(referenceAnswers: [String: Any]) -> String
    {
        var formattedText = self.text
        if let formatSpecifiers = self.formatSpecifiers
        {
            for format in formatSpecifiers
            {
                let replacementValue = referenceAnswers[format.answerIdentifier]
                var replacementString: String
                if replacementValue is String
                {
                    replacementString = replacementValue as! String
                }
                else
                {
                    replacementString = String(replacementValue as! Int)
                }
                formattedText = formattedText.replacingOccurrences(of: format.placeholder, with: replacementString)
            }
        }
        return formattedText
    }
}

struct FormatSpecifier
{
    let placeholder: String
    let answerIdentifier: String
    
    init(withJSON JSON:[String: Any])
    {
        placeholder = JSON["placeholder"] as! String
        answerIdentifier = JSON["answer_identifier"] as! String
    }
}

// MARK: - Flow conditions

enum ConditionComparisonType
{
    case lessThan
    case greaterThan
    case equalTo
}

enum ConditionFunctionType
{
    case AND
    case OR
    case NOT
}

struct Condition
{
    let answerIdentifier: String
    let comparisonType: ConditionComparisonType
    let comparisonValue: Any
    
    init(withJSON JSON:[String: Any])
    {
        answerIdentifier = JSON["answer_identifier"] as! String
        let comparisonJSON = JSON["comparison"] as! String
        switch comparisonJSON
        {
            case "greater_than":
                comparisonType = .greaterThan
            case "less_than":
                comparisonType = .lessThan
            case "equal_to":
                comparisonType = .equalTo
            default:
                comparisonType = .equalTo
        }
        comparisonValue = JSON["comparison_value"] as Any
    }
}

struct ConditionGroup
{
    let conditions: [Condition]?
    let conditionGroups: [ConditionGroup]?
    let function: ConditionFunctionType
    
    init(withJSON JSON:[String: Any])
    {
        if let conditionsJSON = JSON["conditions"] as? [[String: Any]]
        {
            conditionGroups = nil
            
            var conditions = [Condition]()
            for conditionJSON in conditionsJSON
            {
                let condition = Condition(withJSON: conditionJSON)
                conditions.append(condition)
            }
            self.conditions = conditions
        }
        else
        {
            conditions = nil
            
            var conditionGroups = [ConditionGroup]()
            let conditionGroupsJSON = JSON["condition_groups"] as! [[String: Any]]
            for conditionGroupJSON in conditionGroupsJSON
            {
                let conditionGroup = ConditionGroup(withJSON: conditionGroupJSON)
                conditionGroups.append(conditionGroup)
            }
            self.conditionGroups = conditionGroups
        }
        
        let functionJSON = JSON["function"] as! String
        switch functionJSON
        {
            case "OR":
                function = .OR
            case "NOT":
                function = .NOT
            case "AND":
                function = .AND
            default:
                function = .AND
        }
    }
}

// MARK: - Input

enum AnswerType
{
    case text
    case int
}

struct Input
{
    let identifier: String
    let question: TextWithFormat
    let answerParameters: AnswerParameters
    
    init(withJSON JSON:[String: Any])
    {
        identifier = JSON["identifier"] as! String
        question = TextWithFormat(withJSON: JSON["question"] as! [String: Any])
        answerParameters = AnswerParameters(withJSON: JSON["answer_parameters"] as! [String: Any])
    }
}

struct AnswerParameters
{
    let type: AnswerType
    let choices: [Any]?
    
    init(withJSON JSON:[String: Any])
    {
        let typeJSON = JSON["type"] as! String
        switch typeJSON
        {
            case "int":
                type = .int
            case "text":
                type = .text
            default:
                type = .text
        }
        
        choices = JSON["choices"] as? [Any]
    }
}

// MARK: - FlowScreen

enum FlowScreenType
{
    case input
    case takeaway
}

struct FlowScreen
{
    let type: FlowScreenType
    let header: TextWithFormat
    let requiredCondition: ConditionGroup?
    let inputs: [Input]? // mutually exclusive with takeaways
    let takeaways: [TextWithFormat]?  // mutually exclusive with inputs
    let continuePrompt: String?
    
    init(withJSON JSON:[String: Any])
    {
        let typeJSON = JSON["type"] as! String
        switch typeJSON
        {
        case "input":
            type = .input
        case "takeaway":
            type = .takeaway
        default:
            type = .takeaway
        }
        header = TextWithFormat(withJSON: JSON["header"] as! [String: Any])
        if let conditionJSON = JSON["required_condition"] as? [String: Any]
        {
            requiredCondition = ConditionGroup(withJSON: conditionJSON)
        }
        else
        {
            requiredCondition = nil
        }
        
        if let inputsJSON = JSON["inputs"] as? [[String: Any]]
        {
            var inputs = [Input]()
            for inputJSON in inputsJSON
            {
                inputs.append(Input(withJSON: inputJSON))
            }
            self.inputs = inputs
        }
        else
        {
            inputs = nil
        }
        
        if let takeawaysJSON = JSON["takeaways"] as? [[String: Any]]
        {
            var takeaways = [TextWithFormat]()
            for takeawayJSON in takeawaysJSON
            {
                takeaways.append(TextWithFormat(withJSON: takeawayJSON))
            }
            self.takeaways = takeaways
        }
        else
        {
            takeaways = nil
        }
        
        continuePrompt = JSON["continue_prompt"] as? String
    }
}

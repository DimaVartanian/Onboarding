//
//  JSONParser.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/24/17.
//

import Foundation

struct JSONParser
{
    static func parseOnboardingJSON(JSON: [String: Any]) -> [FlowScreen]
    {
        let screensJSON = JSON["onboarding_flow"] as! [[String: Any]]
        var flowScreens = [FlowScreen]()
        for screenJSON in screensJSON
        {
            flowScreens.append(FlowScreen(withJSON: screenJSON))
        }
        return flowScreens
    }
}


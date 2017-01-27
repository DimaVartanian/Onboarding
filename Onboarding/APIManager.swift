//
//  APIManager.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/24/17.
//

import Foundation

struct APIManager
{
    // This method mocks a call to an external API and returns a JSON response
    func fetchOnBoardingInstructions() -> [String : Any]
    {
        let fileName = Bundle.main.path(forResource: "MockServerResponse", ofType: "json")!
        let data = NSData(contentsOfFile: fileName)!
        let JSON = try! JSONSerialization.jsonObject(with: data as Data, options: []) as! [String : Any]
        return JSON
    }
}

//
//  AutoLayoutLabel.swift
//  Onboarding
//
//  Created by Dima Vartanian on 1/25/17.
//

import UIKit

class AutoLayoutLabel: UILabel
{
    override var bounds: CGRect
    {
        didSet
        {
            let newWidth = bounds.size.width
            if preferredMaxLayoutWidth != newWidth
            {
                preferredMaxLayoutWidth = newWidth
            }
        }
        
    }
}

//
//  UITextField+Extension.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/11/24.
//

import Foundation
import UIKit

extension UITextField {
    // MARK: - Placeholder
    func set(placeholder: String, color: UIColor) {
        
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: color
        ]
        
        let range = NSString(string: placeholder).range(of: placeholder)
        let attributedString = NSMutableAttributedString(string: placeholder)
        attributedString.addAttributes(attributes, range: range)
        
        attributedPlaceholder = attributedString
    }
}

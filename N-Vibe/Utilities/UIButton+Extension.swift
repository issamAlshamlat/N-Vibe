//
//  UIButton+Extension.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/11/24.
//

import Foundation
import UIKit

extension UIButton {
    // MARK: - Set Icon
    func set(icon: UIImage = .empty) {
            setImage(icon.withRenderingMode(.alwaysOriginal), for: .normal)
        
        contentMode = .center
        clipsToBounds = false
        
        contentVerticalAlignment = .center
        contentHorizontalAlignment = .center
    }
}

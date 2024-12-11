//
//  UIimage+Extension.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/11/24.
//

import Foundation
import UIKit

extension UIImage {
    static let empty = UIImage()
}

func img(_ name: String) -> UIImage {
    if let img = UIImage(named: name) {
        return img
    } else {
        return .empty
    }
}

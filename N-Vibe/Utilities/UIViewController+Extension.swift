//
//  UIViewController+Extension.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/11/24.
//

import Foundation
import UIKit

extension UIViewController {
    func showError(message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

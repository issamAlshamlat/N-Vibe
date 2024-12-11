//
//  SpinnerManager.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/11/24.
//

import Foundation
import UIKit

final class SpinnerManager {
    private var spinnerView: UIView?
    
    static let shared = SpinnerManager()
    
    private init() {}
    
    func show(inView view: UIView? = nil) {
        guard spinnerView == nil else { return }
        
        // Create a container view for the spinner
        let containerView = UIView(frame: view?.bounds ?? UIScreen.main.bounds)
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.5) // Semi-transparent background
        containerView.isUserInteractionEnabled = true
        
        // Create the default activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = containerView.center
        activityIndicator.startAnimating()
        
        containerView.addSubview(activityIndicator)
        
        if let targetView = view {
            targetView.addSubview(containerView)
        } else {
            guard let window = UIApplication.shared.windows.first else { return }
            window.addSubview(containerView)
        }
        
        spinnerView = containerView
    }
    
    func hide() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
}

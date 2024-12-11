//
//  FloatingButtonFactory.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/10/24.
//

import Foundation
import UIKit

class FloatingButton: UIButton {
    enum ButtonType {
        case navigation, currentLocation
    }

    init(type: ButtonType) {
        super.init(frame: .zero)
        setupButton(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(type: ButtonType) {
        switch type {
        case .navigation:
            self.set(icon: .navigationArrow)
            self.backgroundColor = .systemBlue
            self.layer.cornerRadius = 30
            self.layer.masksToBounds = true
        case .currentLocation:
            self.set(icon: .userLocation)
            self.backgroundColor = .systemBlue
            self.layer.cornerRadius = 30
            self.layer.masksToBounds = true
        }
    }
}

class ToggleStyleButton: UIButton {
    init() {
        super.init(frame: .zero)
        self.setTitle(.nightMode, for: .normal)
        self.backgroundColor = .systemBlue
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  RouteInfoView.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/11/24.
//

import Foundation
import UIKit

class RouteInfoView: UIView {
    private let distanceLabel = UILabel()
    private let durationLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        self.layer.cornerRadius = 12
        self.isHidden = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Route Details"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        distanceLabel.font = .systemFont(ofSize: 14)
        durationLabel.font = .systemFont(ofSize: 14)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(distanceLabel)
        stackView.addArrangedSubview(durationLabel)
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func updateDistance(_ distance: Double) {
        distanceLabel.text = "Distance: \(String(format: "%.2f", distance / 1000)) km"
    }
    
    func updateDuration(_ duration: TimeInterval) {
        durationLabel.text = "Duration: \(formatTime(duration))"
    }
    
    private func formatTime(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours) hrs \(minutes) mins"
        } else {
            return "\(minutes) mins"
        }
    }
}

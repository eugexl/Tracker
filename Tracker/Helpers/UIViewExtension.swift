//
//  UIViewExtension.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 09.02.2024.
//

import UIKit

extension UIView {
    
    func setGradientBorder(with colors: [UIColor], width: CGFloat, radius: CGFloat) {
        
        let gradient = CAGradientLayer()
        
        gradient.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
}

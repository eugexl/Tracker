//
//  UILabelExtension.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 25.12.2023.
//

import UIKit

extension UILabel {
    
    func generateScheduleList(from trackerSchedule: Set<TrackerSchedule>) {
        
        if trackerSchedule.count == 7 {
            self.text = "Каждый день"
            return
        }
        
        var scheduleList: String = ""
        var delimiter: String = ""
        
        if trackerSchedule.contains(.monday) {
            scheduleList += "Пн"
            delimiter = ", "
        }
        if trackerSchedule.contains(.tuesday) {
            scheduleList += delimiter + "Вт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.wednesday) {
            scheduleList += delimiter + "Ср"
            delimiter = ", "
        }
        if trackerSchedule.contains(.thursday) {
            scheduleList += delimiter + "Чт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.friday) {
            scheduleList += delimiter + "Пт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.saturday) {
            scheduleList += delimiter + "Сб"
            delimiter = ", "
        }
        if trackerSchedule.contains(.sunday) {
            scheduleList += delimiter + "Вс"
        }
        
        self.text = scheduleList
    }
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = .center
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

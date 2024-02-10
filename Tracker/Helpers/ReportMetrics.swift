//
//  ReportMetrics.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 08.02.2024.
//

import Foundation
import YandexMobileMetrica

struct ReportMetrics {
    static func reportMerics(screen: String, event: String, item: String) {
        
        let params: [AnyHashable : Any] = [
            "event": event,
            "screen": screen,
            "item": item
        ]
        
        YMMYandexMetrica.reportEvent("EVENT", parameters: params)
    }
}

//
//  AnalyticsView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-26.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseAnalyticsSwift

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {
        
    }
    
    func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 40) {
            Button {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_Button1_click")
            } label: {
                Text("Tap me.. 1")
            }
            
            Button {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_Button2_click", params: ["button_number":"2"])
            } label: {
                Text("Tap me... 2")
            }
        }
//        .analyticsScreen(name: "AnalyticsView")
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Appear")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Disappear")
            
            AnalyticsManager.shared.setUserId("123d13f12f1")
            
            AnalyticsManager.shared.setUserProperty(value: true.description, forName: "isAdmin")
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}

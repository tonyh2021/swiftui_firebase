//
//  CrashView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-26.
//

import SwiftUI
import FirebaseCrashlytics

final class CrashManager {
    
    static let shared = CrashManager()
    
    private init() {
        
    }
    
    func setupUserId(_ userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    func setValue(_ value: String, forKey key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func recordError(_ error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}


struct CrashView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 30) {
                Button {
                    CrashManager.shared.log("Button 1 tapped")
                    let s1: String? = nil
                    let s2 = s1!
                } label: {
                    Text("Tap me... 1")
                }
                
                Button {
                    CrashManager.shared.log("Button 2 tapped")
                    fatalError("Oh, crash!")
                } label: {
                    Text("Tap me... 2")
                }
                
                Button {
                    CrashManager.shared.log("Button 3 tapped")
                    let array: [String] = []
                    let a = array[1]
                } label: {
                    Text("Tap me... 3")
                }
                
                Button {
                    CrashManager.shared.log("Button 4 tapped")
                    CrashManager.shared.recordError(URLError(.badServerResponse))
                } label: {
                    Text("Tap me... 4")
                }
            }
        }
        .onAppear {
            CrashManager.shared.setupUserId("c1312u1dku1hku")
            CrashManager.shared.setValue("true", forKey: "isAadmin")
            CrashManager.shared.log("crash view appeared")
        }
    }
}

struct CrashView_Previews: PreviewProvider {
    static var previews: some View {
        CrashView()
    }
}

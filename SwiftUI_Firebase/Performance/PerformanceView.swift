//
//  PerformanceView.swift
//  SwiftUI_Firebase
//
//  Created by Tony on 2023-04-26.
//

import SwiftUI
import FirebasePerformance

final class PerformanceManager {
    
    static let shared = PerformanceManager()
    private init() {
        
    }
    
    private var traces: [String: Trace] = [:]
    
    func startTrace(name: String) {
        guard let trace = Performance.startTrace(name: name) else {
            return
        }
        traces[name] = trace
    }
    
    func setValue(name: String, value: String, forAttribute attribute: String) {
        guard let trace = traces[name] else {
            return
        }
        trace.setValue(value, forAttribute: attribute)
    }
    
    func stopTrace(name: String) {
        guard let trace = traces[name] else {
            return
        }
        trace.stop()
        traces.removeValue(forKey: name)
    }
}

struct PerformanceView: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                configure()
                loadData()
                
                PerformanceManager.shared.startTrace(name: "PerformanceView")
            }
            .onDisappear {
                PerformanceManager.shared.stopTrace(name: "PerformanceView")
            }
    }
    
    private func configure() {
        
        let trace = Performance.startTrace(name: "\(String(describing: PerformanceView.self))_trace")
        trace?.setValue("Hello...", forAttribute: "title")
        
        Task {
            trace?.setValue("Start loading", forAttribute: "load")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            trace?.setValue("loading", forAttribute: "load")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            trace?.setValue("loading", forAttribute: "load")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            trace?.setValue("Finish loading", forAttribute: "load")
            trace?.stop()
        }
    }
    
    private func loadData() {
        guard let url = URL(string: "https://dummyjson.com/products"), let metric = HTTPMetric(url: url, httpMethod: .get) else {
            return
        }
        metric.start()
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                if let response = response as? HTTPURLResponse {
                    metric.responseCode = response.statusCode
                }
                metric.stop()
                print("Success")
            } catch {
                print("Error: \(error)")
                metric.stop()
            }
        }
    }
}

struct PerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceView()
    }
}

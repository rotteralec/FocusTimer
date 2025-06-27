//
//  ContentView.swift
//  FocusTimer Watch App
//
//  Created by Al Rotter on 6/25/25.
//

import SwiftUI
import WatchKit


struct WatchHapticView: View {
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
                    Text("Watch Haptic Timer")
                        .font(.headline)
                        .padding()

                    Button("Start Haptics") {
                        startHaptics()
                    }
                    .padding()

                    Button("Stop Haptics") {
                        stopHaptics()
                    }
                    .padding()
                }
                .onDisappear {
                    // Ensure timer is stopped if the view disappears
                    stopHaptics()
                }
    }
    
    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.failure)
        print("Playing watch haptic...")
    }
    
    func startHaptics() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            playHapticFeedback()
            
        }
        print("Haptics Started")
    }
    
    func stopHaptics() {
        timer?.invalidate()
        timer = nil
        print("Haptics stopped.")
    }
    
    
}

struct WatchHapticView_Previews: PreviewProvider {
    static var previews: some View {
        WatchHapticView()
    }
}


//
//struct ContentView: View {
//    @State private var currentDate = Date.now
//    @State var countDown: Int = 0
//    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
//
//    var body: some View {
//        Text("\(countDown)")
//            .onReceive(timer) { input in
//                countDown = Int(round(input.timeIntervalSince(currentDate)))
//                WKInterfaceDevice.currentDevice().play
//            }
//    }
//}



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
    // Use a @State variable for the interval, initialized to 5 seconds
    @State private var intervalSeconds: Double = 5.0
    @State private var isHapticsRunning: Bool = false

    var body: some View {
        VStack {
            Text("Haptic Interval")
                .font(.headline)
                .padding(.bottom, 1)

            // Display the current interval, formatted as a whole number
            Text("\(Int(intervalSeconds)) seconds")
                .font(.title2)
                .foregroundColor(.accentColor)
                .padding(.bottom, 10)

            // Stepper to adjust the interval
            // Using a Stepper automatically enables Digital Crown interaction for the value
            Stepper(value: $intervalSeconds, in: 1.0...600.0, step: 1.0) {
                Text("Adjust Interval")
                    .font(.footnote)
            }
            .padding(.horizontal)
            .disabled(isHapticsRunning) // Disable stepper when haptics are running

            Spacer()

            if isHapticsRunning {
                Button("Stop Haptics") {
                    stopHaptics()
                }
                .tint(.red) // Make the stop button red
            } else {
                Button("Start Haptics") {
                    startHaptics()
                }
                .tint(.green) // Make the start button green
            }
        }
        .onDisappear {
            // Ensure timer is stopped if the view disappears
            stopHaptics()
        }
        // Apply the digital crown rotation effect directly to the view for wider target
        .focusable() // Make the view focusable for digital crown
        .digitalCrownRotation($intervalSeconds, from: 1.0, through: 600.0, by: 1.0, sensitivity: .low)
    }

    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.notification) // Play a notification haptic
        print("Playing watch haptic at interval: \(Int(intervalSeconds)) seconds")
    }

    func startHaptics() {
        // Invalidate any existing timer to prevent multiple timers running
        timer?.invalidate()

        // Schedule a new timer with the user-selected interval
        timer = Timer.scheduledTimer(withTimeInterval: intervalSeconds, repeats: true) { _ in
            playHapticFeedback()
        }
        isHapticsRunning = true
        print("Haptics started with interval: \(Int(intervalSeconds)) seconds.")
    }

    func stopHaptics() {
        timer?.invalidate()
        timer = nil
        isHapticsRunning = false
        print("Haptics stopped.")
    }
}

struct WatchHapticView_Previews: PreviewProvider {
    static var previews: some View {
        WatchHapticView()
    }
}
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



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
    
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 5
    
    @State private var isHapticsRunning: Bool = false
    private var wheelWidth: CGFloat = 40.0
    
    var totalInterval: TimeInterval {
        Double(selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds)
    }

    var body: some View {
            VStack {
                Text("Haptic Interval")
                    .font(.headline)
                    .padding(.bottom, 1)

                // MARK: - Time Pickers (Scrollable Wheels)
                HStack {
                    // Hours Picker
                    Picker("H", selection: $selectedHours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: wheelWidth)
                    .clipped() // Crucial for preventing text overflow

                    // Minutes Picker
                    Picker("M", selection: $selectedMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: wheelWidth) // Adjust width
                    .clipped()

                    // Seconds Picker
                    Picker("S", selection: $selectedSeconds) {
                        ForEach(0..<60) { second in
                            Text("\(second)").tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: wheelWidth)
                    .clipped()
                }
                .padding(.horizontal, -8) // Slightly reduce horizontal padding if needed
                .disabled(isHapticsRunning) // Disable pickers when haptics are running

                Spacer()

                // MARK: - Start/Stop Buttons
                if isHapticsRunning {
                    Button("Stop Haptics") {
                        stopHaptics()
                    }
                    .tint(.red)
                } else {
                    Button("Start Haptics") {
                        startHaptics()
                    }
                    .tint(.green)
                    .disabled(totalInterval <= 0) // Disable start if interval is 0 or less
                }
            }
            .onDisappear {
                stopHaptics()
            }
        }

    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.notification) // Play a notification haptic
        print("Playing watch haptic at interval: \(Int(totalInterval)) seconds")
    }

    func startHaptics() {
        // Invalidate any existing timer to prevent multiple timers running
        timer?.invalidate()

        // Schedule a new timer with the user-selected interval
        timer = Timer.scheduledTimer(withTimeInterval: totalInterval, repeats: true) { _ in
            playHapticFeedback()
        }
        isHapticsRunning = true
        print("Haptics started with interval: \(Int(totalInterval)) seconds.")
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



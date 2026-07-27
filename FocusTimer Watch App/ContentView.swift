//
//  ContentView.swift
//  FocusTimer Watch App
//
//  Created by Al Rotter on 6/25/25.
//

import SwiftUI
import WatchKit


class ExtendedRuntimeManager: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    @Published var isSessionActive = false
    @Published var sessionError: String?
    
    private var session: WKExtendedRuntimeSession?
    
    func startSession() {
        if (session != nil) {session?.invalidate()}
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        print("Starting extended runtime session...")
    }
    
    func stopSession() {
        session?.invalidate()
        session = nil
        isSessionActive = false
        print("Stopped extended runtime session")
    }
    
    // MARK: - WKExtendedRuntimeSessionDelegate Methods
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        DispatchQueue.main.async {
            self.isSessionActive = true
            print("Extended runtime session started successfully")
        }
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        DispatchQueue.main.async {
            print("Warning: Session will expire soon")
        }
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, 
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, 
                                error: Error?) {
        DispatchQueue.main.async {
            self.isSessionActive = false
            
            let reasonString: String
            switch reason {
            case .none:
                reasonString = "No specific reason"
            case .expired:
                reasonString = "Session time limit reached"
            case .sessionInProgress:
                reasonString = "Another session is already in progress"
            case .resignedFrontmost:
                reasonString = "App resigned frontmost"
            case .suppressedBySystem:
                reasonString = "Suppressed by system"
            case .error:
                reasonString = "Error occurred"
            @unknown default:
                reasonString = "Unknown reason"
            }
            
            print("Session invalidated: \(reasonString)")
            if let error = error {
                self.sessionError = error.localizedDescription
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}


struct WatchHapticView: View {
    @State private var timer: Timer?
    
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 5
    
    @StateObject private var runtimeManager = ExtendedRuntimeManager()  // Add this
    
    @State private var isHapticsRunning: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    private var wheelWidth: CGFloat = 40.0
    
    var totalInterval: TimeInterval {
        Double(selectedMinutes * 60 + selectedSeconds)
    }
    
    //Center label  countdown
    var timeString: String {
        let t = Int(timeRemaining.rounded())
        let m = (t % 3600) / 60
        let s = t % 60
        return String(format: "%d:%02d", m, s)
    }
    
    var progress: CGFloat {
        guard totalInterval > 0 else { return 0 }
        return CGFloat(timeRemaining / totalInterval)
    }
    
    var body: some View {
            VStack {
                // MARK: - Start/Stop Buttons
                if isHapticsRunning {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.green,
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timeRemaining)
                        
                        Text(timeString)
                            .font(.title3)
                            .monospacedDigit()
                    }
                    .padding()
                    Button("Stop") {
                        stopHaptics()
                    }
                    .tint(.red)
                    .font(.caption2)
                } else {
                    Text("Haptic Interval")
                        .font(.headline)
                        .padding(.bottom, 1)
                    // MARK: - Time Pickers (Scrollable Wheels)
                    HStack {
                        
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
                    Button("Start") {
                        startHaptics()
                    }
                    .tint(.green)
                    .font(.caption)
                    .disabled(totalInterval <= 0) // Disable start if interval is 0 or less
                }
            }
            .onDisappear {
                stopHaptics()
            }
            .onChange(of: runtimeManager.isSessionActive) { oldValue, newValue in
                if !newValue && isHapticsRunning {
                    print("Warning: Runtime session ended, stopping haptics")
                    stopHaptics()
                }
            }
        }

    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.notification) // Play a notification haptic
        print("Playing watch haptic at interval: \(Int(totalInterval)) seconds")
    }

    func startHaptics() {
        // Start the extended runtime session first
        runtimeManager.startSession()
        
        // Invalidate any existing timer to prevent multiple timers running
        timer?.invalidate()
        
        timeRemaining = totalInterval

        // Schedule a new timer with the user-selected interval
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining <= 1 {
                playHapticFeedback()
                timeRemaining = totalInterval
            } else {
                timeRemaining -= 1
            }
            
        }
        isHapticsRunning = true
        print("Haptics started with interval: \(Int(totalInterval)) seconds.")
    }

    func stopHaptics() {
        timer?.invalidate()
        timer = nil
        isHapticsRunning = false
        
        // Stop the extended runtime session
        runtimeManager.stopSession()
        
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



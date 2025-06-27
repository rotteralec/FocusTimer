  //
//  ContentView.swift
//  FocusTimer
//
//  Created by Al Rotter on 6/25/25.
//

import SwiftUI
import CoreHaptics


struct HapticView: View {
    @State private var hapticEngine: CHHapticEngine?
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            Text("Haptic Timer App")
                .font(.largeTitle)
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
        .onAppear {
            prepareHaptics()
        }
        .onDisappear {
            stopHaptics()
            hapticEngine?.stop(completionHandler: nil)
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Haptics is not supported on this device.")
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.playsHapticsOnly = true //Optional: Ensures engine only plays haptics
            hapticEngine?.stoppedHandler = { reason in
                print("Engine Stopped: \(reason.rawValue)")
            }
            try hapticEngine?.start()
        } catch {
            print("Error creating haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playHapticFeedback() {
        guard let hapticEngine = hapticEngine else { return }
        
        //Create a basic haptic event for a vibration
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print ("Failed to play haptic: \(error.localizedDescription)")
        }
    }
    
    func startHaptics() {
        //Invalidate any existing timer to prevent multiple timers running
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                playHapticFeedback()
                print("Playing haptic....")
        }
    }
    
    func stopHaptics() {
        timer?.invalidate()
        timer = nil
        print("Haptics stopped.")
    }
    
    
    
    
}

struct HaptivView_Previews: PreviewProvider {
    static var previews: some View {
        HapticView()
    }
}
//struct ContentView: View {
//    @State private var currentDate = Date.now
//    @State var countDown: Double = 0
//    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
//
//    var body: some View {
//        Text("\(countDown)")
//            .onReceive(timer) { input in
//                countDown = round(input.timeIntervalSince(currentDate))
//                print(Date.now)
//                print(countDown)
//            }
//            .sensoryFeedback(.impact, trigger: countDown)
//    }
//}
//
//
//#Preview {
//    ContentView()
//}

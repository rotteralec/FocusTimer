//
//  ContentView.swift
//  FocusTimer Watch App
//
//  Created by Al Rotter on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date.now
    @State var countDown: Int = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        Text("\(countDown)")
            .onReceive(timer) { input in
                countDown = Int(round(input.timeIntervalSince(currentDate)))
                print(Date.now)
                print(countDown)
            }
    }
}

#Preview {
    ContentView()
}

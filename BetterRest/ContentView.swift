//
//  ContentView.swift
//  BetterRest
//
//  Created by surya sai on 09/01/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var WakeUP = Date.now
    @State private var sleepAmout = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment:.leading) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Sampe",selection: $WakeUP,displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment:.leading) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmout.formatted()) hours",value: $sleepAmout,in: 4...12,step: 0.25)
                }
                VStack(alignment:.leading) {
                    Text("Daily coffee intake")
                    Stepper("\(coffeeAmount.formatted()) cup(s)",value: $coffeeAmount,in: 0...20,step: 1)
                }
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate"){calculateBedtime()}
            }
            .alert(alertTitle,isPresented: $showAlert, actions: {
                Button("OK"){}
            },message: {Text(alertMessage)})
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: WakeUP)
            let hour = (components.hour ?? 0) * 60 * 60
            let min = (components.minute ?? 0) *  60
            
            let prediction = try model.prediction(wake: Int64(hour + min), estimatedSleep: sleepAmout, coffee: Int64(coffeeAmount))
            let sleepTime =  WakeUP - prediction.actualSleep
            
            alertTitle = "Your calculated BedTime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
            
        }
        
        showAlert = true
        
        
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  BetterRest1
//
//  Created by Brian Krause on 9/2/22.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            VStack{
                
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper(coffeeAmount == 1 ? "1 Cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                
                    .alert(alertTitle, isPresented: $showingAlert){
                        Button("OK") {}
                    } message: {
                        Text(alertMessage)
                    }
                }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            }
        }
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalcMod(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0 ) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem while calculating your bedtime"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

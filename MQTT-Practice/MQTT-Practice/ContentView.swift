//
//  ContentView.swift
//  MQTT-Practice
//
//  Created by 박신영 on 9/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mqttManager = MQTTManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("MQTT Practice App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connection Status:")
                    .font(.headline)
                
                Text(mqttManager.connectionStatus)
                    .foregroundColor(mqttManager.isConnected ? .green : .red)
                
                Button(action: {
                    if mqttManager.isConnected {
                        mqttManager.disconnect()
                    } else {
                        mqttManager.connect()
                    }
                }) {
                    Text(mqttManager.isConnected ? "Disconnect" : "Connect")
                        .foregroundColor(.white)
                        .padding()
                        .background(mqttManager.isConnected ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

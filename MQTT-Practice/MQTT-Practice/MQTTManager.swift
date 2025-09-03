import Foundation
import CocoaMQTT

class MQTTManager: ObservableObject {
    @Published var isConnected = false
    @Published var connectionStatus = "Disconnected" 
    @Published var receivedMessages: [MQTTMessage] = []
    
    private var mqttClient: CocoaMQTT?
    let clientID = "iOS-Client-\(UUID().uuidString)"
    
    private let defaultHost = "broker.hivemq.com"
    private let defaultPort: UInt16 = 1883
    
    init() {
        setupMQTT()
    }
    
    private func setupMQTT() {
        mqttClient = CocoaMQTT(clientID: clientID, host: defaultHost, port: defaultPort)
        mqttClient?.username = ""
        mqttClient?.password = ""
        mqttClient?.keepAlive = 60
        mqttClient?.delegate = self
        mqttClient?.autoReconnect = true
        mqttClient?.autoReconnectTimeInterval = 1
    }
    
    func connect() {
        guard let mqttClient = mqttClient else { return }
        
        DispatchQueue.main.async {
            self.connectionStatus = "Connecting..."
        }
        
        _ = mqttClient.connect()
    }
    
    func disconnect() {
        mqttClient?.disconnect()
        DispatchQueue.main.async {
            self.connectionStatus = "Disconnecting..."
        }
    }
    
    func publish(topic: String, message: String, qos: CocoaMQTTQoS = .qos1) {
        guard isConnected, let mqttClient = mqttClient else {
            print("MQTT not connected")
            return
        }
        
        mqttClient.publish(topic, withString: message, qos: qos)
    }
    
    func subscribe(topic: String, qos: CocoaMQTTQoS = .qos1) {
        guard isConnected, let mqttClient = mqttClient else {
            print("MQTT not connected")
            return
        }
        
        mqttClient.subscribe(topic, qos: qos)
    }
    
    func unsubscribe(topic: String) {
        mqttClient?.unsubscribe(topic)
    }
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            if ack == .accept {
                self.isConnected = true
                self.connectionStatus = "Connected to \(self.defaultHost)"
                print("MQTT Connected")
            } else {
                self.connectionStatus = "Connection failed: \(ack)"
                print("MQTT Connection failed: \(ack)")
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Published message: \(message.string ?? "") to topic: \(message.topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Message published successfully, id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        DispatchQueue.main.async {
            let mqttMessage = MQTTMessage(
                id: UUID(),
                topic: message.topic,
                message: message.string ?? "",
                timestamp: Date()
            )
            self.receivedMessages.append(mqttMessage)
            print("Received message: \(message.string ?? "") from topic: \(message.topic)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("Subscribed to topics: \(success), failed: \(failed)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("Unsubscribed from topics: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT Ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT Pong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            if let error = err {
                self.connectionStatus = "Disconnected with error: \(error.localizedDescription)"
            } else {
                self.connectionStatus = "Disconnected"
            }
            print("MQTT Disconnected")
        }
    }
}

struct MQTTMessage: Identifiable {
    let id: UUID
    let topic: String
    let message: String
    let timestamp: Date
}
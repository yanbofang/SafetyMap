//
//  FirstViewController.swift
//  SafetyMap
//
//  Created by Yanbo Fang on 10/29/16.
//  Copyright © 2016 Yanbo Fang. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import UserNotifications

var isGrantedNotificationAccess:Bool = false

class FirstViewController: UIViewController, SFSpeechRecognizerDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var isGrantedNotificationAccess:Bool = false
    
    public func askPermission() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    // Good to go
                    break
                case .denied:
                    // User said no
                    break
                case .restricted:
                    // Device isn't permitted
                    break
                case .notDetermined:
                    // Don't know yet
                    break
                }
            }
        }
    }
    
    func sendNotification() {
        if isGrantedNotificationAccess{
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Friend in Danger!"
            content.subtitle = "From SafetyMap"
            content.body = "Your friend is in danger! Open SafetyMap to locate your friend!"
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 0.0,
                repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "0.second.message",
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
            
        }
    }
    
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ask for permission to send notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
        
        
        // Disable the record buttons until authorization has been granted.
        //recordButton.isEnabled = false
        try! startRecording()
    }
    
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString.lowercased()
                if transcription.range(of: "help") != nil{
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.textView.text = transcription
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(Go ahead, I'm listening)"
    }
    
 
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


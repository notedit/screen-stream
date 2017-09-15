//
//  FirstViewController.swift
//  screen-stream-swift
//
//  Created by Gong Zhang on 2017/9/15.
//  Copyright © 2017年 dotEngine. All rights reserved.
//

import UIKit
import ReplayKit

let APP_KEY = "45"
let APP_SECRET = "dc5cabddba054ffe894ba79c2910866c"
let ROOM = "screen_stream"

class FirstViewController: UIViewController, RPScreenRecorderDelegate, DotEngineDelegate, DotStreamDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var screenRecorder: RPScreenRecorder!
    var dotEngine: DotEngine!
    var localStream: DotStream!
    var videoCapturer: DotVideoCapturer?
    
    var isStarted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenRecorder = RPScreenRecorder.shared()
        screenRecorder.delegate = self
        
        dotEngine = DotEngine.sharedInstance(with: self)
        localStream = DotStream(audio: true, video: true, videoProfile: DotEngineVideoProfile.DotEngine_VideoProfile_480P, delegate: self)
        
        videoCapturer = DotVideoCapturer()
        localStream.videoCaptuer = videoCapturer
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm A"
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] t in
            guard let me = self else {
                t.invalidate()
                return
            }
            me.timeLabel.text = formatter.string(from: Date())
        }
    }
    
    @IBAction func buttonStartAction(_ sender: Any) {
        guard !isStarted else {
            return
        }
        
        let randomNum = arc4random_uniform(10000)
        let userId = "stream\(randomNum)"
        
        localStream.setupLocalMedia()
        
        dotEngine.generateTestToken(withAppKey: APP_KEY, appsecret: APP_SECRET, room: ROOM, userId: userId) { [weak self] (token, err) in
            guard err == nil else {
                print(err!)
                return
            }
            
            guard let token = token else {
                print("token is nil")
                return
            }
            
            self?.dotEngine.joinRoom(withToken: token)
        }
        
        screenRecorder.startCapture(handler: { (sampleBuffer, bufferType, err) in
            
            // TODO: 应该缩放一下屏幕
            // TODO: 目前先只支持视频
            
            if bufferType == .video {
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
                CVPixelBufferLockBaseAddress(imageBuffer, [])
                
                let pixelFormatType = CVPixelBufferGetPixelFormatType(imageBuffer)
                
                if pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
                    pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                    // only nv12 support
                    print("kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange")
                    
                    if let videoCapture = self.videoCapturer {
                        videoCapture.send(imageBuffer, rotation: .roation_0)
                    }
                    
                }
                
                CVPixelBufferUnlockBaseAddress(imageBuffer, [])
            }
            
        }) { [weak self] err in
            if err == nil {
                self?.isStarted = true
            } else {
                print(err!)
            }
        }
    }
    
    @IBAction func buttonStopAction(_ sender: Any) {
        guard isStarted else {
            return
        }
        
        screenRecorder.stopCapture { [weak self] err in
            if let err = err {
                print(err)
            }
            self?.isStarted = false
        }
    }
    
    // MARK: - RPScreenRecorder Delegates
    
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        print("screenRecorderDidChangeAvailability \(screenRecorder.isAvailable)")
    }
    
    // MARK: - DotEngine Delegates
    
    func dotEngine(_ engine: DotEngine, didJoined peerId: String) {
        print("didJoined")
    }
    
    func dotEngine(_ engine: DotEngine, didLeave peerId: String) {
        print("didLeave")
    }
    
    func dotEngine(_ engine: DotEngine, stateChange state: DotStatus) {
        if state == .connected {
            dotEngine.add(localStream)
        }
    }
    
    func dotEngine(_ engine: DotEngine, didAddLocalStream stream: DotStream) {
        print("didAddLocalStream")
    }
    
    func dotEngine(_ engine: DotEngine, didRemoveLocalStream stream: DotStream) {
    }
    
    func dotEngine(_ engine: DotEngine, didAddRemoteStream stream: DotStream) {
    }
    
    func dotEngine(_ engine: DotEngine, didRemoveRemoteStream stream: DotStream) {
    }
    
    func dotEngine(_ engine: DotEngine, didOccurError errorCode: DotEngineErrorCode) {
        print("didOccurError \(errorCode)")
    }
    
    // MARK: - DotStream Delegates
    
    func stream(_ stream: DotStream?, didMutedVideo muted: Bool) {
    }
    
    func stream(_ stream: DotStream?, didMutedAudio muted: Bool) {
    }
    
    func stream(_ stream: DotStream?, didGotAudioLevel audioLevel: Int32) {
    }
    
}

//
//  ViewController.swift
//  screen-stream-watch-swift
//
//  Created by Gong Zhang on 2017/9/15.
//  Copyright © 2017年 dotEngine. All rights reserved.
//

import UIKit

let APP_KEY = "45"
let APP_SECRET = "dc5cabddba054ffe894ba79c2910866c"
let ROOM = "screen_stream"

class ViewController: UIViewController, DotEngineDelegate, DotStreamDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    
    var dotEngine: DotEngine!
    var localStream: DotStream!
    var remoteStream: DotStream?
    
    var isStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dotEngine = DotEngine.sharedInstance(with: self)
        localStream = DotStream(audio: true, video: false, delegate: self)
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        startButton.isEnabled = false
        
        localStream.setupLocalMedia()
        
        let randomNum = arc4random_uniform(10000)
        let userId = "watch\(randomNum)"
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
            startButton.isHidden = true
        }
    }
    
    func dotEngine(_ engine: DotEngine, didAddLocalStream stream: DotStream) {
        print("didAddLocalStream")
    }
    
    func dotEngine(_ engine: DotEngine, didRemoveLocalStream stream: DotStream) {
    }
    
    func dotEngine(_ engine: DotEngine, didAddRemoteStream stream: DotStream) {
        remoteStream = stream
        stream.view?.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        stream.view?.scaleMode = .fit
        
        view.addSubview(stream.view!)
    }
    
    func dotEngine(_ engine: DotEngine, didRemoveRemoteStream stream: DotStream) {
        guard let remoteStream = remoteStream else {
            return
        }
        
        if remoteStream.streamId == stream.streamId {
            remoteStream.view?.removeFromSuperview()
            self.remoteStream = nil
        }
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


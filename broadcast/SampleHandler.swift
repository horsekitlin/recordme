//
//  SampleHandler.swift
//  broadcast
//
//  Created by 林暐秦 on 2019/12/3.
//  Copyright © 2019 imappUITests. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        print("broadcastStarted")
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional. 
    }
    
    override func broadcastPaused() {
        print("broadcastPaused")
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        print("broadcastResumed")
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        print("broadcastFinished")
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        
        switch sampleBufferType {
        case RPSampleBufferType.video:
            print("RPSampleBufferType.video")
            // Handle video sample buffer
            break
        case RPSampleBufferType.audioApp:
            print("RPSampleBufferType.audioApp")
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            print("RPSampleBufferType.audioMic")
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}

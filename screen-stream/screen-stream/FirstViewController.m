//
//  FirstViewController.m
//  screen-stream
//
//  Created by xiang on 13/09/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import "FirstViewController.h"

#import <ReplayKit/ReplayKit.h>

#import <DotEngine.h>
#import <DotStream.h>
#import <DotVideoCapturer.h>

static  NSString*  APP_KEY = @"";
static  NSString*  APP_SECRET = @"";
static  NSString*  ROOM = @"";



@interface FirstViewController ()<RPScreenRecorderDelegate,DotEngineDelegate,DotStreamDelegate>
{
    RPScreenRecorder *screenRecorder;
    
    DotEngine* dotEngine;
    DotStream* localStream;
    DotVideoCapturer* videoCapturer;
    BOOL isStarted;
}

@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    screenRecorder = [RPScreenRecorder sharedRecorder];
    screenRecorder.delegate = self;
    
    dotEngine = [DotEngine sharedInstanceWithDelegate:self];
    localStream = [[DotStream alloc] initWithAudio:YES
                                             video:YES
                                      videoProfile:DotEngine_VideoProfile_480P
                                          delegate:self];
    
    videoCapturer = [[DotVideoCapturer alloc] init];
    localStream.videoCaptuer = videoCapturer;
    
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 0.2
                                                  target: self
                                                selector:@selector(onTick)
                                                userInfo: nil repeats:YES];
    
    [t fire];
}



-(void)onTick {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm A"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    self.timeLable.text = formattedDateString;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startCapture:(id)sender {
    // startCaptureWithHandler
    
    if (isStarted) {
        return;
    }
    
    uint32_t randomNum = arc4random_uniform(10000);
    
    NSString* userId = [NSString stringWithFormat:@"stream%d",randomNum];
    
    [localStream setupLocalMedia];
    
    [dotEngine generateTestTokenWithAppKey:APP_KEY
                                 appsecret:APP_SECRET
                                      room:ROOM
                                    userId:userId
                                 withBlock:^(NSString *token, NSError *error) {
                                     
                                     if (token != nil) {
                                         [dotEngine joinRoomWithToken:token];
                                     }
                                    }];
    
    [screenRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
        
        // TODO  应该缩放一下屏幕 
        // 目前先只支持视频
        if (bufferType == RPSampleBufferTypeVideo) {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            CVPixelBufferLockBaseAddress(imageBuffer, 0);
            
            
            OSType pixelFormatType = CVPixelBufferGetPixelFormatType(imageBuffer);
            
            if(pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
               pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange){
                // only nv12 support
                NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ");
                
                if (videoCapturer != nil) {
                    [videoCapturer sendCVPixelBuffer:imageBuffer
                                            rotation:VideoRoation_0];
                }
            }
            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        }
        
        
    } completionHandler:^(NSError * _Nullable error) {
        
        if (error != nil) {
            isStarted = true;
        }
    }];
}

- (IBAction)stopCapture:(id)sender {
    
    //stopCaptureWithHandler
    if (!isStarted) {
        return;
    }
    [screenRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
        isStarted = false;
    }];
}


#pragma RPScreenRecorderDelegate delegate

- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(nullable RPPreviewViewController *)previewViewController
{
    
}


- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder
{
    NSLog(@"screenRecorderDidChangeAvailability %d", screenRecorder.available);
}

#pragma DotEngine Delegate


-(void)dotEngine:(DotEngine* _Nonnull) engine didJoined:(NSString* _Nonnull)peerId
{
    NSLog(@"didJoined ");
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didLeave:(NSString* _Nonnull)peerId
{
    NSLog(@"didLeave");
}

-(void)dotEngine:(DotEngine* _Nonnull) engine  stateChange:(DotStatus)state
{
    if (state == DotStatusConnected) {
        [dotEngine addStream:localStream];
    }
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didAddLocalStream:(DotStream* _Nonnull)stream
{
    NSLog(@"didAddLocalStream");
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didRemoveLocalStream:(DotStream* _Nonnull)stream
{
    
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didAddRemoteStream:(DotStream* _Nonnull)stream
{
    
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didRemoveRemoteStream:(DotStream* _Nonnull) stream
{
    
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didOccurError:(DotEngineErrorCode)errorCode
{
    
    NSLog(@"didOccurError  %ld", (long)errorCode);
}


#pragma DotStream delegate


-(void)stream:(DotStream* _Nullable)stream  didMutedVideo:(BOOL)muted
{
    
}

-(void)stream:(DotStream* _Nullable)stream  didMutedAudio:(BOOL)muted
{
    
}

-(void)stream:(DotStream* _Nullable)stream  didGotAudioLevel:(int)audioLevel
{
    
}

@end

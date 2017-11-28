//
//  FirstViewController.m
//  screen-stream
//
//  Created by xiang on 13/09/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import "FirstViewController.h"


#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

#import <DotEngine.h>
#import <DotStream.h>
#import <DotVideoCapturer.h>


#import "CVPixelBufferResize.h"

static  NSString*  APP_KEY = @"45";
static  NSString*  APP_SECRET = @"dc5cabddba054ffe894ba79c2910866c";
static  NSString*  ROOM = @"screen_test";


@interface FirstViewController ()<DotEngineDelegate,DotStreamDelegate,ARSCNViewDelegate, ARSessionDelegate>
{
    
    DotEngine* dotEngine;
    DotStream* localStream;
    DotVideoCapturer* videoCapturer;
    BOOL isStarted;
    
    NSDate* lastDate;
    CVPixelBufferResize* resize;
    
    CADisplayLink *displayLink;
}


@property (weak, nonatomic) IBOutlet ARSCNView *sceneView;

@property (nonatomic, strong) SCNRenderer *renderer;
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, assign) CGSize outputSize;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sceneView.delegate = self;
    
    self.sceneView.showsStatistics = YES;
    
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    self.sceneView.scene = scene;
    self.sceneView.session.delegate = self;
    
    self.renderer = [SCNRenderer rendererWithDevice:nil options:nil];
    self.renderer.scene = scene;
    
    self.videoQueue = dispatch_queue_create("cc.dot.video.queue", NULL);
    
    
    dotEngine = [DotEngine sharedInstanceWithDelegate:self];
    localStream = [[DotStream alloc] initWithAudio:YES
                                             video:YES
                                      videoProfile:DotEngine_VideoProfile_480P
                                          delegate:self];
    
    videoCapturer = [[DotVideoCapturer alloc] init];
    localStream.videoCaptuer = videoCapturer;
    
    resize = [[CVPixelBufferResize alloc] init];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.outputSize = self.sceneView.frame.size;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
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
    
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCaptureData)];
    displayLink.preferredFramesPerSecond =  15;  // 每秒15帧 可以自己调整
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (IBAction)stopCapture:(id)sender {
    
    //stopCaptureWithHandler
    if (!isStarted) {
        return;
    }
    if (displayLink!= nil) {
        [displayLink invalidate];
        displayLink = nil;
    }
    isStarted = false;
}


-(CVPixelBufferRef)capturePixelBuffer {
    
    UIImage *image = [self.renderer snapshotAtTime:1 withSize:CGSizeMake(self.outputSize.width, self.outputSize.height) antialiasingMode:SCNAntialiasingModeMultisampling4X];
    
    CIImage* ciimage = [[CIImage alloc] initWithCGImage:image.CGImage];
    
    CVPixelBufferRef  pixelBuffer = [resize processCIImage:ciimage];
    return pixelBuffer;
}


-(void)getCaptureData
{
    NSLog(@"getCaptureData ");
    
    dispatch_async(self.videoQueue, ^{
        CVPixelBufferRef pixelBuffer = [self capturePixelBuffer];
        if (pixelBuffer) {
            [videoCapturer sendCVPixelBuffer:pixelBuffer rotation:VideoRoation_0];
             CFRelease(pixelBuffer);
        } else {
            NSLog(@"can not get pixel buffer ");
        }
        
    });
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
        //[dotEngine addStream:localStream];
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


#pragma  ARSessionDelegate


- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
    NSLog(@"didUpdateFrame ");
}

- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors
{
    
    
}


- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors
{
    
    
}


- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors
{
    
}

@end

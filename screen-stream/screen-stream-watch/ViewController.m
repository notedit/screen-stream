//
//  ViewController.m
//  screen-stream-watch
//
//  Created by xiang on 14/09/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import "ViewController.h"

#import <DotEngine.h>
#import <DotStream.h>


static  NSString*  APP_KEY = @"45";
static  NSString*  APP_SECRET = @"dc5cabddba054ffe894ba79c2910866c";
static  NSString*  ROOM = @"screen_stream";


@interface ViewController ()<DotEngineDelegate,DotStreamDelegate>
{
    
    DotEngine* dotEngine;
    DotStream* localStream;
    DotStream* remoteStream;
    
    BOOL isStarted;
}


@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dotEngine = [DotEngine sharedInstanceWithDelegate:self];
    localStream = [[DotStream alloc] initWithAudio:YES
                                             video:NO
                                          delegate:self];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    
    self.startButton.enabled = false;
    
    [localStream setupLocalMedia];
    
    uint32_t randomNum = arc4random_uniform(10000);
    
    NSString* userId = [NSString stringWithFormat:@"watch%d",randomNum];
    
    [dotEngine generateTestTokenWithAppKey:APP_KEY
                                 appsecret:APP_SECRET
                                      room:ROOM
                                    userId:userId withBlock:^(NSString *token, NSError *error) {
                                        if (error == nil) {
                                            [dotEngine joinRoomWithToken:token];
                                        }
                                    }];
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
        self.startButton.hidden = true;
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
    remoteStream = stream;
    
    remoteStream.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [remoteStream.view setScaleMode:DotVideoViewScaleModeFit];
    
    [self.view addSubview:remoteStream.view];
}

-(void)dotEngine:(DotEngine* _Nonnull) engine didRemoveRemoteStream:(DotStream* _Nonnull) stream
{
    if (remoteStream != nil && [remoteStream.streamId isEqualToString:stream.streamId]) {
        [remoteStream.view removeFromSuperview];
    }
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

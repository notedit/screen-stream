//
//  FirstViewController.m
//  screen-stream
//
//  Created by xiang on 13/09/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import "FirstViewController.h"

#import <ReplayKit/ReplayKit.h>


@interface FirstViewController ()<RPScreenRecorderDelegate>
{
    RPScreenRecorder *screenRecorder;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    screenRecorder = [RPScreenRecorder sharedRecorder];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startCapture:(id)sender {
    // startCaptureWithHandler
}

- (IBAction)stopCapture:(id)sender {
    
    //stopCaptureWithHandler
}


#pragma delegate

- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(nullable RPPreviewViewController *)previewViewController
{


}



- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder
{
    
    
}


@end

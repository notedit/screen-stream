# screen-stream
screen stream 



此工程分为两个target, screen-stream 用来直播屏幕并进行音频通话

screen-stream-watch 用来观看屏幕直播以及音频通话 


## screen-stream

### RPScreenRecorder

这里主要用了RPScreenRecorder 的两个方法 startCaptureWithHandler 和 stopCaptureWithHandler

startCaptureWithHandler 开启之后会收到屏幕的数据  并通过DotEngine推送出去 

### DotEngine

这里主要是使用了DotVideoCaptuer, DotVideoCaptuer 可以把CVPixelbuffer 推送出去, 
CVPixelbuffer 目前只支持 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange和
kCVPixelFormatType_420YpCbCr8BiPlanarFullRange

更多详细的使用文档在 http://docs.dot.cc


## screen-stream-watch

screen-stream-watch的作用是接搜远程的音视频并只发布本地的音频 所以本地DotStream 初始化的时候只需要初始化音频

```
    localStream = [[DotStream alloc] initWithAudio:YES
                                             video:NO
                                          delegate:self];
```

另外需要注意的是如果要完整显示对方屏幕需要设置

```
 [remoteStream.view setScaleMode:DotVideoViewScaleModeFit];

```

更多详细的使用文档在 http://docs.dot.cc

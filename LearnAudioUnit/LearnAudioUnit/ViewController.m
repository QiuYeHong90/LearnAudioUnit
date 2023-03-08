//
//  ViewController.m
//  LearnAudioUnit
//
//  Created by Ray on 2023/2/28.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#define subPathPCM @"/Documents/record.pcm"
#define kInputBus (1)
#define kOutputBus (0)
#define stroePath [NSHomeDirectory() stringByAppendingString:subPathPCM]
@interface ViewController ()
{
    AudioUnit remoteIOUnit;
    double _sampleRate;
    UInt32 channels;
}
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end

@implementation ViewController
static OSStatus inputCallBackFun(    void *                            inRefCon,
                                 AudioUnitRenderActionFlags *    ioActionFlags,
                                 const AudioTimeStamp *            inTimeStamp,
                                 UInt32                            inBusNumber,
                                 UInt32                            inNumberFrames,
                                 AudioBufferList * __nullable    ioData)
{
    
    ViewController *recorder = (__bridge ViewController *)(inRefCon);
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    
    AudioUnitRender(recorder->remoteIOUnit,
                    ioActionFlags,
                    inTimeStamp,
                    kInputBus,
                    inNumberFrames,
                    &bufferList);
    
//    //回调中写 函数
//    recorder ->recorderTempBuffer = malloc(CONST_BUFFER_SIZE);
//
//    typeof(recorder) __weak weakSelf = recorder;
//    typeof(weakSelf) __strong strongSelf = weakSelf;
//
    AudioBuffer buffer = bufferList.mBuffers[0];
    int len = buffer.mDataByteSize;
//    memcpy(strongSelf->recorderTempBuffer, buffer.mData, len);

    [recorder writeBytes:buffer.mData len:len toPath:stroePath];
    

    
    return noErr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sampleRate = 44100;
    channels = 1;
    [self configSession];
    [self ioUnitGet];
    [self connectMicphoneAndSpeaker];
    
    
    
    
}
static void CheckStatus(OSStatus status, NSString *message, BOOL fatal) {
    
    if(status != noErr) {
        char fourCC[16]; *(UInt32 *)fourCC = CFSwapInt32HostToBig(status); fourCC[4] = '\0';
        if (isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3]))
            NSLog(@"%@: %s", message, fourCC);
        else
            NSLog(@"%@: %d", message, (int)status);
        
        if(fatal) exit(-1);
        
    }
}

- (void)writeBytes:(Byte *)bytes len:(NSUInteger)len toPath:(NSString *)path
{
    NSData *data = [NSData dataWithBytes:bytes length:len];
    [self writeData:data toPath:path];
}

- (void)writeData:(NSData *)data toPath:(NSString *)path
{
    NSString *savePath = path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] == false)
    {
        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:savePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
}
-(void)configSession {
    NSError * error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    NSTimeInterval bufferDuration = 0.002;
    [audioSession setPreferredIOBufferDuration:bufferDuration error:&error];
    
    double hwSampleRate = _sampleRate;
    [audioSession setPreferredSampleRate:hwSampleRate error:&error];
    [audioSession setActive:YES error:&error];
}

-(void)ioUnitGet {
    AudioComponentDescription ioUnitDescription;
    ioUnitDescription.componentType = kAudioUnitType_Output;
    ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    ioUnitDescription.componentManufacturer=kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags = 0;
    ioUnitDescription.componentFlagsMask = 0;
    
    
    AudioComponent ioUnitRef = AudioComponentFindNext(NULL, &ioUnitDescription);
    AudioUnit ioUnitInstance;
    
    AudioComponentInstanceNew(ioUnitRef, &ioUnitInstance);
    
    AUGraph processingGraph;
    NewAUGraph (&processingGraph);
    
    AUNode ioNode;
    AUGraphAddNode (processingGraph, &ioUnitDescription, &ioNode);
    
    AUGraphOpen (processingGraph);
    AudioUnit ioUnit;
    AUGraphNodeInfo(processingGraph, ioNode, NULL, &ioUnit);
    remoteIOUnit = ioUnit;
}


-(void)connectMicphoneAndSpeaker {
    OSStatus status = noErr;
    UInt32 oneFlag = 1;
    UInt32 busZero = kOutputBus;// Element 0
    status = AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, busZero, &oneFlag, sizeof(oneFlag));
    CheckStatus(status, @"Could not Connect To Speaker", YES);
    
    
    UInt32 busOne = kInputBus; // Element 1
    AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, busOne, &oneFlag, sizeof(oneFlag));
    
    
    
    UInt32 bytesPerSample = sizeof(Float32);
    AudioStreamBasicDescription asbd;
    bzero(&asbd, sizeof(asbd));
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mSampleRate = _sampleRate;
    asbd.mChannelsPerFrame = channels;
    asbd.mFramesPerPacket = 1;
    asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mBitsPerChannel = 8 * bytesPerSample;
    asbd.mBytesPerFrame = bytesPerSample;
    asbd.mBytesPerPacket = bytesPerSample;
    
    
    AudioUnitSetProperty( remoteIOUnit,kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &asbd, sizeof(asbd));
    
    
    AURenderCallbackStruct renderProc;
    renderProc.inputProc = &inputCallBackFun;
    renderProc.inputProcRefCon = (__bridge void *)self;
//    AUGraphSetNodeInputCallback(mGraph, ioNode, 0, &renderProc);
    
    status = AudioUnitSetProperty(remoteIOUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &renderProc,
                                  sizeof(renderProc));
}

-(void)start {
    AudioOutputUnitStart(remoteIOUnit);
    NSLog(@"stroePath == %@",stroePath);
}

-(void)stop {
    
    CheckStatus(AudioOutputUnitStop(remoteIOUnit), @"AudioOutputUnitStop failed", NO);
    CheckStatus(AudioComponentInstanceDispose(remoteIOUnit),
               @"AudioComponentInstanceDispose failed", NO);
}
- (IBAction)startClick:(id)sender {
    [self start];
}
- (IBAction)stopClick:(id)sender {
    [self stop];
}

@end

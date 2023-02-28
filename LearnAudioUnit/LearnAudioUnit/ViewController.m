//
//  ViewController.m
//  LearnAudioUnit
//
//  Created by Ray on 2023/2/28.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>

@interface ViewController ()
{
    AudioUnit remoteIOUnit;
    double _sampleRate;
    UInt32 channels;
}
@end

@implementation ViewController

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
    UInt32 busZero = 0;// Element 0
    status = AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, busZero, &oneFlag, sizeof(oneFlag));
    CheckStatus(status, @"Could not Connect To Speaker", YES);
    
    
    UInt32 busOne = 1; // Element 1
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
    renderProc.inputProc = &RecordCallback;
    renderProc.inputProcRefCon = (__bridge void *)self;
//    AUGraphSetNodeInputCallback(mGraph, ioNode, 0, &renderProc);
}

//static OSStatus RecordCallback(void *inRefCon,
//                               AudioUnitRenderActionFlags *ioActionFlags,
//                               const AudioTimeStamp *inTimeStamp,
//                               UInt32 inBusNumber,
//                               UInt32 inNumberFrames,
//                               AudioBufferList *ioData)
// {
//    ViewController *vc = (__bridge ViewController *)inRefCon;
//    vc->buffList->mNumberBuffers = 1;
//    OSStatus status = AudioUnitRender(vc->outputUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, vc->buffList);
//    if (status != noErr) {
//        NSLog(@"AudioUnitRender error:%d", status);
//    }
//    NSLog(@"RecordCallback size = %d", vc->buffList->mBuffers[0].mDataByteSize);
//    [vc writePCMData:vc->buffList->mBuffers[0].mData size:vc->buffList->mBuffers[0].mDataByteSize];
//    return noErr;
//}
@end

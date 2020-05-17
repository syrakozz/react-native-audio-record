  
#import <AVFoundation/AVFoundation.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>

@interface RNAudioRecord : RCTEventEmitter <RCTBridgeModule>
    @property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *aTimer;
@end

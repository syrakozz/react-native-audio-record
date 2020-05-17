#import "RNAudioRecord.h"

@implementation RNAudioRecord

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(init:(NSDictionary *) options) {
    RCTLogInfo(@"init");
  
    ////
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                                AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                                AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                                AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
     
     NSError *error;
    
    NSArray *dirPaths;
      NSString *docsDir;

      dirPaths = NSSearchPathForDirectoriesInDomains(
           NSDocumentDirectory, NSUserDomainMask, YES);
      docsDir = dirPaths[0];

       NSString *soundFilePath = [docsDir
          stringByAppendingPathComponent:@"sound.caf"];

      NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
 //   NSURL *soundFileURL = [NSURL fileURLWithPath:@"/dev/null"];
     self.recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:settings error:&error];
     
     if(error) {
         NSLog(@"Ups, could not create recorder %@", error);
         return;
     }

     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
     
     if (error) {
         NSLog(@"Error setting category: %@", [error description]);
         return;
     }
   
   
}

RCT_EXPORT_METHOD(start) {
    RCTLogInfo(@"start");

  [self.recorder prepareToRecord];
     [self.recorder setMeteringEnabled:YES];
     [self.recorder record];
    self.aTimer = [NSTimer timerWithTimeInterval:(0.1f) target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.aTimer forMode:NSDefaultRunLoopMode];
      [self.aTimer fire];
    
}

- (void)timerFired:(NSTimer*)theTimer
{
     [self updateMeters];
}

RCT_EXPORT_METHOD(stop:(RCTPromiseResolveBlock)resolve
                  rejecter:(__unused RCTPromiseRejectBlock)reject) {
    RCTLogInfo(@"stop %@",[self.recorder.url path]);
    [self.aTimer invalidate];
    [self.recorder stop];
    resolve([self.recorder.url path]);
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"data"];
}

- (void)dealloc {
    RCTLogInfo(@"dealloc");
}

- (void)updateMeters
{
    CGFloat normalizedValue;
            [self.recorder updateMeters];
            normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
        
    RCTLogInfo(@"normalizedValue %f",normalizedValue);
    
    [self sendEventWithName:@"data" body:[NSString stringWithFormat:@"%f",normalizedValue]];
}

#pragma mark - Private
- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

@end

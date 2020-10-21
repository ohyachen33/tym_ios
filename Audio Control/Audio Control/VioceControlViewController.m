//
//  VioceControlViewController.m
//  Audio Control
//
//  Created by Alain Hsu on 9/21/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "VioceControlViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AlexaControl.h"
#import "AmazonLoginDelegate.h"
#import "SystemManager.h"
#import "TonescapePlot.h"
#import "PopButton.h"

@interface VioceControlViewController ()<AmazonLoginResultsDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,CAAnimationDelegate,PopButtonDelegate>
{
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    NSURL *_fileUrl;
    
    NSString *_speechToken;
    
    BOOL _recording;
    NSTimeInterval slientTime;
}
@property (strong,nonatomic) PopButton *toneBtn;

@property (weak, nonatomic) IBOutlet UILabel *deviceProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkProgressLabel;
@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (nonatomic,strong) CAShapeLayer *pulseLayer;
@property (nonatomic,strong) CAAnimationGroup *groupAnima;

@property (nonatomic, strong)id connectionObserver;

@property (nonatomic,strong) NSDictionary *serverStatus;

@end

@implementation VioceControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureToneBtn];
    [self setupRecordingAnimations];
    
    [self getStatusFromServer];
    
    [AmazonLoginDelegate sharedInstance].delegate = self;
    
    //request access for microphone
    [AVCaptureDevice  requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
        if (granted){
            
        }else {
            
        }
    }];
    
    if ([SystemManager sharedManager].connectedSystem) {
        self.toneBtn.userInteractionEnabled = YES;
        [self fetchFromSystem];
    }
    
    self.connectionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SystemStateDidUpdate object:nil queue:nil usingBlock:^(NSNotification* note){
        if ([SystemManager sharedManager].state == SystemBLEStateConnected) {
            self.toneBtn.userInteractionEnabled = YES;
            [self fetchFromSystem];
        }else{
            self.toneBtn.userInteractionEnabled = NO;
        }
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //check login
    [[AmazonLoginDelegate sharedInstance] checkAlexaUserStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AlexaControl shareInstance] stop];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.connectionObserver];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

-(void)configureToneBtn {
    self.toneBtn = [[PopButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40) tittle:@"test" tittleColor:[UIColor whiteColor]];
    
    self.toneBtn.delegate = self;
    
    // Configure item buttons
    //
    PopItemButton *itemButton_1 = [[PopItemButton alloc]initWithTittle:@"warm"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_2 = [[PopItemButton alloc]initWithTittle:@"energetic"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_3 = [[PopItemButton alloc]initWithTittle:@"soft"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_4 = [[PopItemButton alloc]initWithTittle:@"bright"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_5 = [[PopItemButton alloc]initWithTittle:@"reset"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    
    [self.toneBtn addPathItems:@[itemButton_1,
                                 itemButton_2,
                                 itemButton_3,
                                 itemButton_4,
                                 itemButton_5
                                 ]];
    
    
    self.toneBtn.bloomRadius = 120.0f;
    
    // Change the DCButton's center
    //
    self.toneBtn.buttonCenter = CGPointMake(50,50);
    
    // Setting the DCButton appearance
    //
    self.toneBtn.allowSounds = YES;
    self.toneBtn.allowCenterButtonRotation = NO;
    
    self.toneBtn.bloomDirection = PopButtonBloomDirectionBottomRight;
    self.toneBtn.bottomViewColor = [UIColor clearColor];
    
    self.toneBtn.userInteractionEnabled = NO;
    
    [self.view addSubview:self.toneBtn];

}

- (IBAction)loginBtnTapped:(id)sender {
    
    [[AmazonLoginDelegate sharedInstance] requestALEXAauth];
    
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        NSLog(@"printing vc %@", topViewController);
        topViewController = topViewController.presentedViewController;
    }
    NSLog(@"printing vc %@", topViewController);
    
}

- (IBAction)logout:(id)sender {
    
    [[AmazonLoginDelegate sharedInstance] requestLogOut];
}

- (IBAction)askBtnTapped:(id)sender {
    
    self.deviceProgressLabel.text = @"";
    self.networkProgressLabel.text = @"";
    
    if (_recording) {
        return;
    }
    _recording = YES;
    [self setupRecorder];
    [self synchronizeServerWithClient];

    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_recordBtn.layer setValue:@(.9) forKeyPath:@"transform.scale"];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_recordBtn.layer setValue:@(1.2) forKeyPath:@"transform.scale"];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.06 delay:0.01 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_recordBtn.layer setValue:@(.9) forKeyPath:@"transform.scale"];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.06 delay:0.01 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [_recordBtn.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
                    
                } completion:^(BOOL finished) {
    
                    [_pulseLayer addAnimation:_groupAnima forKey:@"groupAnimation"];

                    [_recorder record];
                    
                }];
            }];
        }];
    }];
}

- (IBAction)stopRecording:(id)sender {
    [_recorder stop];
}

#pragma mark - Set up recorder
- (void)setupRecorder {
    
    NSString *urlStr = [NSTemporaryDirectory() stringByAppendingPathComponent:@"audio.wav"];
    
    if (!_recorder) {
        _fileUrl = [NSURL fileURLWithPath:urlStr];
        
        NSDictionary *info = @{
                               AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                               AVSampleRateKey:@16000,
                               AVNumberOfChannelsKey:@1,
                               AVLinearPCMBitDepthKey:@16,
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVEncoderAudioQualityKey:[NSNumber numberWithInt:AVAudioQualityMin],
                               
                               };
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        [session setCategory:AVAudioSessionCategoryRecord error:&setCategoryError];
        
        if(setCategoryError){
            NSLog(@"%@", [setCategoryError description]);
        }
        
        _recorder = [[AVAudioRecorder alloc]initWithURL:_fileUrl settings:info error:nil];
        
        [_recorder prepareToRecord];
        
        [_recorder recordForDuration:10];
        
        _recorder.delegate = self;
        
        _recorder.meteringEnabled = YES;

    }else{
        //remove previous record
        [[NSFileManager defaultManager]removeItemAtPath:urlStr error:nil];

    }
}

- (void)setupRecordingAnimations {
    
    _pulseLayer = [CAShapeLayer layer];
    _pulseLayer.frame = _recordView.layer.bounds;
    _pulseLayer.path = [UIBezierPath bezierPathWithOvalInRect:_pulseLayer.bounds].CGPath;
    _pulseLayer.fillColor = [UIColor blackColor].CGColor;
    _pulseLayer.opacity = 0.0;
    
    //Copy layer
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = _recordView.bounds;
    replicatorLayer.instanceCount = 4;
    replicatorLayer.instanceDelay = 0.5;
    [replicatorLayer addSublayer:_pulseLayer];
    [_recordView.layer addSublayer:replicatorLayer];
    
    CABasicAnimation *opacityAnima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnima.fromValue = @(0.5);
    opacityAnima.toValue = @(0.0);
    
    CABasicAnimation *scaleAnima = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnima.fromValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0.0)];
    scaleAnima.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.0)];
    
    _groupAnima = [CAAnimationGroup animation];
    _groupAnima.animations = @[opacityAnima, scaleAnima];
    _groupAnima.duration = 2.0;
    _groupAnima.autoreverses = NO;
    _groupAnima.repeatCount = HUGE;
}

#pragma mark - PopButtonDelegate

- (void)popButton:(PopButton *)popButton clickItemButtonAtIndex:(NSUInteger)itemButonIndex
{
    NSData *toneData;
    
    switch (itemButonIndex) {
        case 0:{
            toneData = [self setupToneDataWithX:-1 andY:[SystemManager sharedManager].systemSettings.EQy /10.0];
        }
            break;
        case 1:{
            toneData = [self setupToneDataWithX:[SystemManager sharedManager].systemSettings.EQx /10.0 andY:1];
        }
            break;
        case 2:{
            toneData = [self setupToneDataWithX:[SystemManager sharedManager].systemSettings.EQx /10.0 andY:-1];
        }
            break;
        case 3:{
            toneData = [self setupToneDataWithX:1 andY:[SystemManager sharedManager].systemSettings.EQy /10.0];
        }
            break;
        case 4:{
            toneData = [self setupToneDataWithX:0 andY:0];
        }
            break;
        default:
            break;
    }
    [self writeTonescape:toneData];
}


#pragma mark - Tonescape
- (void)writeTonescape:(NSData*)toneData {
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem datapacket:toneData tonescape:^(id complet) {
        [SystemManager sharedManager].systemSettings.EQx = [TonescapePlot readX:toneData];
        [SystemManager sharedManager].systemSettings.EQy = [TonescapePlot readY:toneData];
        [SystemManager sharedManager].systemSettings.EQz = [TonescapePlot readZ:toneData];
        
        NSString *eqx;
        if ( [SystemManager sharedManager].systemSettings.EQx > 0) {
            eqx = @"bright";
        }else if ( [SystemManager sharedManager].systemSettings.EQx < 0 ) {
            eqx = @"warm";
        }else {
            eqx = @"";
        }
        
        NSString *eqy;
        if ( [SystemManager sharedManager].systemSettings.EQy > 0) {
            eqy = @"energetic";
        }else if ( [SystemManager sharedManager].systemSettings.EQy < 0 ) {
            eqy = @"soft";
        }else {
            eqy = @"";
        }
        
        NSString *tone;
        if (eqx.length > 0 && eqy.length > 0) {
            tone = [NSString stringWithFormat:@"%@&%@",eqx,eqy];
        }else if (eqx.length == 0 && eqy.length > 0) {
            tone = [NSString stringWithFormat:@"%@",eqy];
        }else if (eqx.length > 0 && eqy.length == 0) {
            tone = [NSString stringWithFormat:@"%@",eqx];
        }else if (eqx.length == 0 && eqy.length == 0) {
            tone = @"nature";
        }
        
        [self.deviceProgressLabel setText:[NSString stringWithFormat:@"write success!\ncurrent tone is %@ tone",tone]];
    }];
}

- (void)fetchFromSystem {
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem tonescape:^(id result) {
        if (result) {
            NSData *value = result;
            
            [SystemManager sharedManager].systemSettings.EQx = [TonescapePlot readX:value];
            [SystemManager sharedManager].systemSettings.EQy = [TonescapePlot readY:value];
            [SystemManager sharedManager].systemSettings.EQz = [TonescapePlot readZ:value];
            
        }
    }];
    
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem batteryLevel:^(NSString* batteryLevel){
        
        [SystemManager sharedManager].systemSettings.batteryLevel = [batteryLevel integerValue];
    }];

}

- (NSData*)setupToneDataWithX:(float)x andY:(float)y {
    int volume = [[SystemManager sharedManager].systemSettings.volume intValue]/4;
    
    float z = [SystemManager sharedManager].systemSettings.EQz /10.0;
    
    return [TonescapePlot datapacketWithVolume:volume power:0 x:x y:y z:z];
}

#pragma mark - Alexa Voice Service
- (void)connectToAVS {
    [[AlexaControl shareInstance] start:^(id responseObj) {
        NSDictionary *dic = responseObj;
        
        NSLog(@"dic==%@",dic);
        
        NSNumber *sleep = dic[@"sleep"];
        NSNumber *controller = dic[@"controller"];
        NSNumber *x = dic[@"x"];
        NSNumber *y = dic[@"y"];
        
        NSInteger xValue = [x integerValue];
        NSInteger yValue = [y integerValue];
        NSInteger sleepValue = [sleep integerValue];
        NSInteger controllerValue = [controller integerValue];

        if ([SystemManager sharedManager].state == SystemBLEStateConnected) {
            
            if (sleepValue != [SystemManager sharedManager].systemSettings.powerStatus) {
                TAPSystemServicePowerStatus powerStatus = sleepValue == 0 ? TAPSystemServicePowerStatusOn : TAPSystemServicePowerStatusCompletelyOff;
                [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem turnPowerStatus:powerStatus completion:^(id complete){
                    [SystemManager sharedManager].systemSettings.powerStatus = sleepValue;
                    [self.deviceProgressLabel setText:sleepValue == 0 ? @"wake up success":@"sleep success"];
                }];

            }
            if (controllerValue != [SystemManager sharedManager].systemSettings.playStatus) {
                switch (controllerValue) {
                    case 0:{
                        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem pause:^(TAPPlayControlServicePlayStatus status) {
                            [SystemManager sharedManager].systemSettings.playStatus = 0;
                            [self.deviceProgressLabel setText:@"pause success"];
                        }];
                    }
                        break;
                    case 1:{
                        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem play:^(TAPPlayControlServicePlayStatus status) {
                            [SystemManager sharedManager].systemSettings.playStatus = 1;
                            [self.deviceProgressLabel setText:@"play success"];
                        }];
                    }
                        break;
                    case 2:{
                        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem previous:^(id result) {
                            [self.deviceProgressLabel setText:@"playing previous song"];
                        }];
                    }
                        break;
                    case 3:{
                        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem next:^(id result) {
                            [self.deviceProgressLabel setText:@"playing next song"];
                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
            if (xValue != [SystemManager sharedManager].systemSettings.EQx || yValue != [SystemManager sharedManager].systemSettings.EQy ) {
                NSData *toneData = [self setupToneDataWithX:xValue/10.0 andY:yValue/10.0];
                [self writeTonescape:toneData];
            }

        }else{
            [self.deviceProgressLabel setText:@"Please connect to a device."];
        }
        
        
    } failure:^(NSError *error) {
        [self.networkProgressLabel setText:@"failed to connect to server"];
    }];
}

- (void)getStatusFromServer {
    
    [[AlexaHTTPRequest shareInstance] getServerStatus:^(id responseObj) {
        self.serverStatus = responseObj;
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)synchronizeServerWithClient {
    
    NSDictionary *status = @{@"connection":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.connection],
                             @"battery":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.batteryLevel],
                             @"sleep":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.powerStatus],
                             @"controller":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.playStatus],
                             @"x":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.EQx],
                             @"y":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.EQy],
                             @"z":[NSNumber numberWithInteger:[SystemManager sharedManager].systemSettings.EQz]
                             };
    NSLog(@"status==%@",status);
    
    if (![self.serverStatus isEqualToDictionary:status]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[AlexaHTTPRequest shareInstance] postTonescapeStatus:status success:^(id responseObj) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.serverStatus = responseObj;
        } failure:^(NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}

- (void)sendRecord {
    [self.networkProgressLabel setText:@"request to Alexa..."];
    self.recordBtn.enabled = NO;
    
    /*
     Start communicating with Alexa!!!
     */
    NSData *audioData = [[NSData alloc]initWithContentsOfURL:_fileUrl];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[AlexaControl shareInstance] speakToAlexa:audioData success:^(id responseObj) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recordBtn.enabled = YES;
            [self.networkProgressLabel setText:@"request succeed!"];
        });
        
        ResponseObject* obj = responseObj;
        
        for (PartData *partData in obj.partDataArray) {
            if ([partData.headers[@"Content-Type"] isEqualToString:@"application/json; charset=UTF-8"]) {
                
                NSString * dataInString = [[NSString alloc]initWithData:partData.data encoding:NSUTF8StringEncoding];
                
//                NSLog(@"dataInString==%@",dataInString);
                
                NSRange range = [dataInString rangeOfString:@"}" options:NSBackwardsSearch];
                if(range.location != NSNotFound){
                    dataInString = [dataInString substringWithRange:NSMakeRange(0,range.location+1)];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[dataInString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                    _speechToken = json[@"directive"][@"payload"][@"token"];
                }
                
            }else if ([partData.headers[@"Content-Type"] isEqualToString:@"application/octet-stream"]){
                
                _player = nil;
                
                AVAudioSession *session = [AVAudioSession sharedInstance];
                NSError *setCategoryError = nil;
                [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
                
                if(setCategoryError){
                    NSLog(@"%@", [setCategoryError description]);
                }
                
                _player = [[AVAudioPlayer alloc]initWithData:partData.data error:nil];
                
                _player.delegate = self;
                
                if (_player) {
                    
                    [_player prepareToPlay];
                    [_player play];
                    
                    
                    //                    if (speechToken) {
                    //                        [[AlexaHTTPRequest shareInstance]requestSpeechSynthesizer:@"SpeechStarted" token:speechToken success:^(id responseObj) {
                    //                            speechToken = nil;
                    //                        } failure:^(NSError *error) {
                    //                            speechToken = nil;
                    //                        }];
                    //                    }
                }
            }
        }
        
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.networkProgressLabel setText:[NSString stringWithFormat:@"Request error:%@",error.localizedDescription]];
            self.recordBtn.enabled = YES;
            
        });
    }];
}

#pragma mark - AmazonLoginResultsDelegate

-(void)authorizationResult:(BOOL)success accessToken:(NSString *)accessToken error:(NSString *)error {
    
    if (success) {
        NSLog(@"access token:%@",accessToken);
        [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"userToken" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.accessToken = accessToken;
        self.amazonLoginButton.hidden = YES;
        self.recordBtn.hidden = NO;
        
        [self connectToAVS];
    
    }else{
        NSLog(@"%@",error);
    }
}

-(void)logOutResult:(BOOL)success error:(NSString *)error {
    
    if (error == nil) {
        [self.networkProgressLabel setText:@"Logout succeed"];
        
        self.amazonLoginButton.hidden = NO;
        self.recordBtn.hidden = YES;
        
    }else{
        [self.networkProgressLabel setText:[NSString stringWithFormat:@"Logout error:%@",error]];
    }
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
//    if (speechToken) {
//        [[AlexaHTTPRequest shareInstance]requestSpeechSynthesizer:@"SpeechFinished" token:speechToken success:^(id responseObj) {
//            speechToken = nil;
//        } failure:^(NSError *error) {
//            speechToken = nil;
//        }];
//    }
     [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    slientTime = 0;
    
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_recordBtn.layer setValue:@(1.1) forKeyPath:@"transform.scale"];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_recordBtn.layer setValue:@(0.9) forKeyPath:@"transform.scale"];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.06 delay:0.02 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_recordBtn.layer setValue:@(1.1) forKeyPath:@"transform.scale"];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.06 delay:0.02 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [_recordBtn.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
                    
                } completion:^(BOOL finished) {
                    [_pulseLayer removeAnimationForKey:@"groupAnimation"];

                    _recording = NO;
                    _recorder =nil;

                    [self sendRecord];
                }];
            }];
        }];
    }];

    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];

}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    
    
}
@end

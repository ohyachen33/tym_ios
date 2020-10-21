//
//  ControlViewController.m
//  Audio Control
//
//  Created by Alain Hsu on 6/29/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "ControlViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SystemManager.h"
#import "PopButton.h"
//#import "TUIKnob.h"
#import "TonescapePlot.h"
#import "MarqueeView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ControlViewController ()<PopButtonDelegate,TAPSystemServiceDelegate>{
    CGFloat radius;
    CGPoint left;
}
#if DEBUG
@property (strong,nonatomic) PopButton *powerButton;
#endif
@property (weak, nonatomic) IBOutlet UILabel *batteryLevel;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UIButton *PlayBTN;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *EQxSlider;
@property (weak, nonatomic) IBOutlet UISlider *EQySlider;
//@property (strong,nonatomic) TUIKnob *volumeKnob;
@property (nonatomic,strong) UIImageView *leftBgImage;
@property (nonatomic,strong) UIImageView *leftHandle;
@property (nonatomic,strong) MarqueeView* MarqueeView;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* battery;
@property(nonatomic, strong) NSString* volume;
@property CGFloat previousValue;
@property(nonatomic, strong) NSMutableDictionary* settings;

@property TAPSystemServicePowerStatus powerStatus;
@property TAPPlayControlServicePlayStatus playbackStatus;
@property TAPPlayControlServiceAudioSource audioSource;

@property NSDate* lastEventTimestamp;
@property NSTimeInterval interval;

@property (nonatomic,strong) id connectionObserver;
@property (nonatomic,strong) id SystemValueObserver;
@property (nonatomic,strong) id playingItemObserver;

@end

@implementation ControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interval = 0.09;

    self.name = nil;
    self.battery = nil;
    self.volume = nil;
#if DEBUG
    [self configurePowerButton];
#endif
    
//    self.volumeKnob = [[TUIKnob alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-100, 200, 200, 200) style:TUIKnobStyleDefault];
//    self.volumeKnob.maximumValue = 127;
//    [self.volumeKnob addObserver:self
//                      forKeyPath:@"value"
//                         options:NSKeyValueObservingOptionNew
//                         context:NULL];
//    [self.view addSubview:self.volumeKnob];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeToTurn) name:@"shake" object:nil];
 
#if DEBUG
    [self setUpToneTouch];
#endif
    
    if ([SystemManager sharedManager].connectedSystem) {
        self.deviceName.text = [(CBPeripheral*)[(TAPSystem*)([SystemManager sharedManager].connectedSystem) instance] name];
        
        //initalize services
        [SystemManager sharedManager].systemService.delegate = self;
        
        [self fetchFromSystem];
        
        [self readTonescape];
        
#if DEBUG
        self.powerButton.userInteractionEnabled = YES;
#endif

    }
    
    self.connectionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:DidConnectedToSystem object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.deviceName.text = [(CBPeripheral*)[(TAPSystem*)([SystemManager sharedManager].connectedSystem) instance] name];
        
        //initalize services
        [SystemManager sharedManager].systemService.delegate = self;
        
        [self fetchFromSystem];
        
#if DEBUG
        self.powerButton.userInteractionEnabled = YES;
#endif
    }];
    
    self.SystemValueObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SystemValueDidUpdate object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([note.userInfo[@"feature"] isEqualToString:@"volume"]) {
            self.volume = [SystemManager sharedManager].systemSettings.volume;
            self.volumeLabel.text = [SystemManager sharedManager].systemSettings.volume;
            self.volumeSlider.value = [[SystemManager sharedManager].systemSettings.volume floatValue];
            //    self.volumeKnob.value = [volume floatValue];
        }else if ([note.userInfo[@"feature"] isEqualToString:@"playStatus"]) {
            switch ([[SystemManager sharedManager].systemSettings.playStatus integerValue]) {
                case TAPPlayControlServicePlayStatusPlay:
                    [self.PlayBTN setTitle:@"Play" forState:0];
                    break;
                case TAPPlayControlServicePlayStatusPause:
                    [self.PlayBTN setTitle:@"Pause" forState:0];
                    break;
                case TAPPlayControlServicePlayStatusStopped:
                    [self.PlayBTN setTitle:@"Stop" forState:0];
                    break;
                default:
                    break;
            }

        }else if ([note.userInfo[@"feature"] isEqualToString:@"powerStatus"]) {
#if DEBUG
            NSString *powerStatus;
            UIColor *color;
            switch ([[SystemManager sharedManager].systemSettings.powerStatus integerValue]) {
                case TAPSystemServicePowerStatusCompletelyOff:
                    powerStatus = @"Off";
                    color = [UIColor lightGrayColor];
                    break;
                case TAPSystemServicePowerStatusOn:
                    powerStatus = @"On";
                    color = [UIColor redColor];
                    break;
                case TAPSystemServicePowerStatusStandbyLow:
                    powerStatus = @"Low";
                    color = [UIColor darkGrayColor];
                    break;
                case TAPSystemServicePowerStatusStandbyHigh:
                    powerStatus = @"High";
                    color = [UIColor blackColor];
                    break;
                case TAPSystemServicePowerStatusUnknown:
                    powerStatus = @"Unknow";
                    color = [UIColor yellowColor];
                    break;
                default:
                    break;
            }
            [self.powerButton setTittle:powerStatus andTittleColor:color];

#endif
        }
        
    }];
    
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    
    _playingItemObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:player queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (_MarqueeView) {
            [_MarqueeView removeFromSuperview];
        }
        MPMediaItem *nowItem = player.nowPlayingItem;
        
        NSString* text = [NSString stringWithFormat:@"%@ - %@",nowItem.title,nowItem.artist];
        
        _MarqueeView = [[MarqueeView alloc] initWithFrame:CGRectMake(40, 100, self.view.frame.size.width - 80, self.view.frame.size.height/2.0 - 160) title:text];
        [self.view addSubview:_MarqueeView];
    

    }];
}

#pragma mark -Tone Touch UI
- (void)setUpToneTouch {
    _leftBgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"j3"]];
    _leftBgImage.backgroundColor = [UIColor clearColor];
    _leftBgImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-95, 205, 190, 190);
//    [self.view addSubview:_leftBgImage];
    
    _leftHandle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"btn_normal"]];
    _leftHandle.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-20, 280, 40, 40);
    _leftHandle.userInteractionEnabled = YES;
//    [self.view addSubview:_leftHandle];
    
    
    radius = 79;
    left = _leftHandle.center;
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanFrom:)];
    [_leftHandle addGestureRecognizer:leftPan];

}

-(void)leftPanFrom:(UIPanGestureRecognizer*)recognizer{
    _leftHandle.image = [UIImage imageNamed:@"btn_pressed"];
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint center = recognizer.view.center;
    center.y += translation.y;
    center.x += translation.x;
    CGFloat x = center.x - left.x;
    CGFloat y = center.y - left.y;
    if (x*x + y*y >= radius*radius)
    {
        center.y -= translation.y;
        center.x -= translation.x;
    }
    NSLog(@"x:%f,y:%f",x,y);
    recognizer.view.center = center;
    [recognizer setTranslation:CGPointZero inView:self.view];
    if (recognizer.state == UIGestureRecognizerStateEnded){
        
        [UIView animateWithDuration:0.08 animations:^{
            _leftHandle.image = [UIImage imageNamed:@"btn_normal"];
        }];
    }
}

- (void)directionForX:(CGFloat)x Y:(CGFloat)y{
    //EQ Control feature
}

#if DEBUG
- (void)configurePowerButton
{
    _powerButton = [[PopButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40) tittle:@"Off" tittleColor:[UIColor whiteColor]];
    
    _powerButton.delegate = self;
    
    // Configure item buttons
    //
    PopItemButton *itemButton_1 = [[PopItemButton alloc]initWithTittle:@"Off"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_2 = [[PopItemButton alloc]initWithTittle:@"On"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_3 = [[PopItemButton alloc]initWithTittle:@"Low"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    PopItemButton *itemButton_4 = [[PopItemButton alloc]initWithTittle:@"High"
                                                           tittleColor:[UIColor whiteColor]
                                                       backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                            backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    

    [_powerButton addPathItems:@[itemButton_1,
                              itemButton_2,
                              itemButton_3,
                              itemButton_4,
                              ]];
    
    
    _powerButton.bloomRadius = 80.0f;
    
    // Change the DCButton's center
    //
    _powerButton.buttonCenter = CGPointMake(50,50);
    
    // Setting the DCButton appearance
    //
    _powerButton.allowSounds = YES;
    _powerButton.allowCenterButtonRotation = NO;
    
    _powerButton.bloomDirection = PopButtonBloomDirectionBottomRight;
    _powerButton.bottomViewColor = [UIColor clearColor];
    
    _powerButton.userInteractionEnabled = NO;
    
    [self.view addSubview:_powerButton];
}
#endif

- (IBAction)playBTNTapped:(id)sender {
    
    if (self.playbackStatus == TAPPlayControlServicePlayStatusPlay) {
        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem pause:^(TAPPlayControlServicePlayStatus status) {
            self.playbackStatus = TAPPlayControlServicePlayStatusPause;
            [self.PlayBTN setTitle:@"Pause" forState:0];
        }];
    }else{
        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem play:^(TAPPlayControlServicePlayStatus status) {
            self.playbackStatus = TAPPlayControlServicePlayStatusPlay;
            [self.PlayBTN setTitle:@"Play" forState:0];
        }];
    }
}

- (IBAction)previousBTNTapped:(id)sender {
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem previous:^(id result) {
        
    }];
}
- (IBAction)nextBTNTapped:(id)sender {
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem next:^(id result) {
        
    }];
}

- (void)shakeToTurn
{
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem next:^(id result) {
        
    }];
}

- (IBAction)EQxChanged:(id)sender {
    BOOL fire = [self shouldFireMessage];
    
    if(fire)
    {
        NSData* toneData = [self setupToneDataWithX:self.EQxSlider.value andY:[[SystemManager sharedManager].systemSettings.EQy integerValue]/10.0];
        self.lastEventTimestamp = [NSDate date];
        [self writeTonescape:toneData];
    }

}

- (IBAction)EQyChanged:(id)sender {
    BOOL fire = [self shouldFireMessage];
    
    if(fire)
    {
        NSData* toneData = [self setupToneDataWithX:[[SystemManager sharedManager].systemSettings.EQx integerValue]/10.0 andY:self.EQySlider.value];
        self.lastEventTimestamp = [NSDate date];
        [self writeTonescape:toneData];
    }
}

- (IBAction)volumeChanged:(id)sender {
//    self.volumeKnob.value = self.volumeSlider.value;
    BOOL fire = [self shouldFireMessage];
    
    if(fire)
    {
        
        CGFloat currentValue = self.volumeSlider.value - self.volumeSlider.minimumValue;
        CGFloat round = roundf(currentValue / 4);
        CGFloat target = (round * 4) + self.volumeSlider.minimumValue;
        
        self.volumeSlider.value = target;
        if(target != self.previousValue)
        {
            self.previousValue = target;
            self.lastEventTimestamp = [NSDate date];
            
            NSInteger value = ((UISlider*)sender).value;
            [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem writeVolume:value completion:^(id complete) {
                
            }];
            [SystemManager sharedManager].systemSettings.volume = [NSString stringWithFormat:@"%ld",value];
            self.volumeLabel.text = [SystemManager sharedManager].systemSettings.volume;
        }
    }
}

- (void)fetchFromSystem
{

        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem volume:^(NSString* volume){
            
            self.volume = volume;
            self.volumeLabel.text = volume;
            self.volumeSlider.value = [volume floatValue];

        }];
        
        [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem deviceName:^(NSString* name){
            
            self.name = name;
            self.deviceName.text = name;
        }];
        
        [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem batteryLevel:^(NSString* batteryLevel){
            
            self.battery = batteryLevel;
            self.batteryLevel.text = [NSString stringWithFormat:@"Battery:%@%%",batteryLevel];
        }];
        
        [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem powerStatus:^(TAPSystemServicePowerStatus powerStatus){
            
            self.powerStatus = powerStatus;
            NSString *status;
            UIColor *color;
            switch (powerStatus) {
                case TAPSystemServicePowerStatusCompletelyOff:
                    status = @"Off";
                    color = [UIColor lightGrayColor];
                    break;
                case TAPSystemServicePowerStatusOn:
                    status = @"On";
                    color = [UIColor redColor];
                    break;
                case TAPSystemServicePowerStatusStandbyLow:
                    status = @"Low";
                    color = [UIColor darkGrayColor];
                    break;
                case TAPSystemServicePowerStatusStandbyHigh:
                    status = @"High";
                    color = [UIColor blackColor];
                    break;
                case TAPSystemServicePowerStatusUnknown:
                    status = @"Unknow";
                    color = [UIColor yellowColor];
                    break;
                default:
                    break;
            }
#if DEBUG
            [self.powerButton setTittle:status andTittleColor:color];
#endif
        }];

        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem playStatus:^(TAPPlayControlServicePlayStatus playStatus){
            
            self.playbackStatus = playStatus;
            switch (playStatus) {
                case TAPPlayControlServicePlayStatusPlay:
                    [self.PlayBTN setTitle:@"Play" forState:0];
                    break;
                case TAPPlayControlServicePlayStatusPause:
                    [self.PlayBTN setTitle:@"Pause" forState:0];
                    break;
                case TAPPlayControlServicePlayStatusStopped:
                    [self.PlayBTN setTitle:@"Stop" forState:0];
                    break;
                default:
                    break;
            }
        }];
        
        [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem audioSource:^(TAPPlayControlServiceAudioSource audioSource){
            
            self.audioSource = audioSource;

        }];
        
}

- (void)subscribeServices
{
    [[SystemManager sharedManager].playControlService startMonitorVolumeOfSystem:[SystemManager sharedManager].connectedSystem];
    [[SystemManager sharedManager].playControlService startMonitorPlayStatusOfSystem:[SystemManager sharedManager].connectedSystem];
    [[SystemManager sharedManager].systemService startMonitorPowerStatusOfSystem:[SystemManager sharedManager].connectedSystem];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
//        self.volumeSlider.value = self.volumeKnob.value;
        BOOL fire = NO;
        
        if(!self.lastEventTimestamp)
        {
            self.lastEventTimestamp = [NSDate date];
            fire = YES;
        }
        else{
            
            if(self.interval <= 0)
            {
                fire = YES;
                
            }else{
                NSDate* now = [NSDate date];
                NSTimeInterval diff =  [now timeIntervalSince1970] - [self.lastEventTimestamp timeIntervalSince1970];
                if(diff >= self.interval)
                {
                    fire = YES;
                }
            }
        }
        
        if(fire)
        {
            
//            CGFloat currentValue = self.volumeKnob.value - self.volumeKnob.minimumValue;
//            CGFloat round = roundf(currentValue / 4);
//            CGFloat target = (round * 4) + self.volumeKnob.minimumValue;
//            
//            self.volumeKnob.value = target;
//            if(target != self.previousValue)
//            {
//                self.previousValue = target;
//                self.lastEventTimestamp = [NSDate date];
//                
//                NSInteger value = self.volumeKnob.value;
//                [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem writeVolume:value completion:^(id complete) {
//                    
//                }];
//                [SystemManager sharedManager].systemSettings.volume = [NSString stringWithFormat:@"%ld",value];
//                self.volumeLabel.text = [SystemManager sharedManager].systemSettings.volume;
//            }
        }

    }
}

-(void)dealloc
{
//    [self.volumeKnob removeObserver:self forKeyPath:@"value"];
    [[NSNotificationCenter defaultCenter] removeObserver:self.connectionObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.SystemValueObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TAPPlayControlServiceDelegate method
- (void)system:(id)system didUpdateAudioSource:(TAPPlayControlServiceAudioSource)audioSource
{
    NSLog(@"didUpdateAudioSource==%ld",(long)audioSource);
}

#pragma mark - Tonescape
- (void)writeTonescape:(NSData*)toneData {
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem datapacket:toneData tonescape:^(id complet) {
        [SystemManager sharedManager].systemSettings.EQx = [NSNumber numberWithInteger:[TonescapePlot readX:toneData]];
        [SystemManager sharedManager].systemSettings.EQy = [NSNumber numberWithInteger:[TonescapePlot readY:toneData]];
        [SystemManager sharedManager].systemSettings.EQz = [NSNumber numberWithInteger:[TonescapePlot readZ:toneData]];
        
    }];
}

- (void)readTonescape {
    [[SystemManager sharedManager].playControlService system:[SystemManager sharedManager].connectedSystem tonescape:^(id result) {
        if (result) {
            NSData *value = result;
            
            [SystemManager sharedManager].systemSettings.EQx = [NSNumber numberWithInteger:[TonescapePlot readX:value]];
            [SystemManager sharedManager].systemSettings.EQy = [NSNumber numberWithInteger:[TonescapePlot readY:value]];
            [SystemManager sharedManager].systemSettings.EQz = [NSNumber numberWithInteger:[TonescapePlot readZ:value]];
            
            self.EQxSlider.value = [[SystemManager sharedManager].systemSettings.EQx floatValue]/10;
            self.EQySlider.value = [[SystemManager sharedManager].systemSettings.EQy floatValue]/10;
        }
    }];
}

- (NSData*)setupToneDataWithX:(float)x andY:(float)y {
    int volume = [[SystemManager sharedManager].systemSettings.volume intValue]==127?32:[[SystemManager sharedManager].systemSettings.volume intValue]/4;
    
    float z = [[SystemManager sharedManager].systemSettings.EQz floatValue]/10;
    
    return [TonescapePlot datapacketWithVolume:volume power:0 x:x y:y z:z];
}

#pragma mark - PopButtonDelegate

- (void)popButton:(PopButton *)popButton clickItemButtonAtIndex:(NSUInteger)itemButonIndex
{
    NSLog(@"You tap %@ at index : %lu", popButton, (unsigned long)itemButonIndex);
    
    TAPSystemServicePowerStatus powerStatus = itemButonIndex;
    [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem turnPowerStatus:powerStatus completion:^(id complete){
        
        //re-fetch the status
        [[SystemManager sharedManager].systemService system:[SystemManager sharedManager].connectedSystem powerStatus:^(TAPSystemServicePowerStatus status){

#if DEBUG
            self.powerStatus = status;
            NSString *powerStatus;
            UIColor *color;
            switch (status) {
                case TAPSystemServicePowerStatusCompletelyOff:
                    powerStatus = @"Off";
                    color = [UIColor lightGrayColor];
                    break;
                case TAPSystemServicePowerStatusOn:
                    powerStatus = @"On";
                    color = [UIColor redColor];
                    break;
                case TAPSystemServicePowerStatusStandbyLow:
                    powerStatus = @"Low";
                    color = [UIColor darkGrayColor];
                    break;
                case TAPSystemServicePowerStatusStandbyHigh:
                    powerStatus = @"High";
                    color = [UIColor blackColor];
                    break;
                case TAPSystemServicePowerStatusUnknown:
                    powerStatus = @"Unknow";
                    color = [UIColor yellowColor];
                    break;
                default:
                    break;
            }
            [self.powerButton setTittle:powerStatus andTittleColor:color];

#endif

        }];
        
    }];
}

#pragma mark - Helper
- (BOOL)shouldFireMessage
{
    BOOL fire = NO;
    
    if(!self.lastEventTimestamp)
    {
        self.lastEventTimestamp = [NSDate date];
        fire = YES;
    }
    else{
        
        if(self.interval <= 0)
        {
            fire = YES;
            
        }else{
            NSDate* now = [NSDate date];
            NSTimeInterval diff =  [now timeIntervalSince1970] - [self.lastEventTimestamp timeIntervalSince1970];
            if(diff >= self.interval)
            {
                fire = YES;
            }
        }
    }
    
    return fire;
}

@end

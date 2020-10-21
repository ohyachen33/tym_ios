//
//  ParametricEQViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 1/12/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import "ParametricEQViewController.h"
#import "UnitLabel.h"
#import "ThemeUtils.h"
#import "SystemManager.h"
#import "CorePlot-CocoaTouch.h"
#import "PEQPlot.h"

@interface ParametricEQViewController ()

@property (nonatomic, strong) IBOutlet UIView * hostView;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segOptions;

@property (nonatomic, strong) IBOutlet UISwitch * swOnOff;
@property (nonatomic, strong) IBOutlet UILabel * lblInputType;
@property (nonatomic, strong) IBOutlet UnitLabel * lblValue;
@property (nonatomic, strong) IBOutlet IntervalSlider * sliderValue;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segInputType;

@property (nonatomic, strong) ActionIntervalFilter * filter;

//core plot
@property (nonatomic, strong) CPTGraphHostingView* graphHostingView;
@property (nonatomic, strong) PEQPlot* plot;

@end

@implementation ParametricEQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblInputType.text = @"Central Frequency";
    
    [ThemeUtils themeUnitLabel:self.lblValue unit:@"Hz"];
    [ThemeUtils themeIntervalSlider:self.sliderValue delegate:self];
    
    [self updateWithUserInfo:nil];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    [tapGestureRecognizer setDelegate:self];
    [self.hostView addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanned:)];
    [panGestureRecognizer setDelegate:self];
    [self.hostView addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer* pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinched:)];
    [pinchGestureRecognizer setDelegate:self];
    [self.hostView addGestureRecognizer:pinchGestureRecognizer];
    
    self.filter = [[ActionIntervalFilter alloc] initWithDelegate:self];
    self.filter.interval = 0.2;
}

- (void)viewDidLayoutSubviews
{
    [self setupGraph];
    [self performSelector:@selector(updateGraph) withObject:nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTapped:(UITapGestureRecognizer*)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self.graphHostingView];
    
    CGFloat freq;
    CGFloat boost;
    
    [self.plot valueOfPoint:point freq:&freq boost:&boost];
    
    [self changeFreq:freq boost:boost fire:YES];
}

- (void)onPanned:(UIPanGestureRecognizer*)panGestureRecognizer
{    
    static CGPoint startPeak;
    static CGPoint previous;
    
    switch (panGestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            startPeak = [self.plot pointOfPeakOfIndex:self.segOptions.selectedSegmentIndex];
            previous = CGPointZero;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            CGPoint newPeak = CGPointMake(startPeak.x + translation.x, startPeak.y + translation.y);

            CGFloat freq;
            CGFloat boost;
            
            [self.plot valueOfPoint:newPeak freq:&freq boost:&boost];
            
            freq = MAX(freq, 20.0);
            freq = MIN(freq, 200.0);
            boost = MAX(boost, -12.0);
            boost = MIN(boost, 6.0);
            
            [self.filter event:@{@"action" : @"pan",  @"freq" : [NSNumber numberWithFloat:freq], @"boost" : [NSNumber numberWithFloat:boost]}];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            CGPoint newPeak = CGPointMake(startPeak.x + translation.x, startPeak.y + translation.y);
            
            CGFloat freq;
            CGFloat boost;
            
            [self.plot valueOfPoint:newPeak freq:&freq boost:&boost];
            
            freq = MAX(freq, 20.0);
            freq = MIN(freq, 200.0);
            boost = MAX(boost, -12.0);
            boost = MIN(boost, 6.0);
            
            [self changeFreq:freq boost:boost fire:YES];

        }
            break;
            
        default:
            break;
    }
}

- (void)onPinched:(UIPinchGestureRecognizer*)pinchGestureRecognizer
{
    CGFloat scale = pinchGestureRecognizer.scale;
    static CGFloat startQ;
    
    switch (pinchGestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            switch (self.segOptions.selectedSegmentIndex) {
                case 0:
                {
                    startQ = [[SystemManager sharedManager].systemSettings.pEq1QFactor floatValue];
                }
                    break;
                case 1:
                {
                    startQ = [[SystemManager sharedManager].systemSettings.pEq2QFactor floatValue];
                }
                    break;
                case 2:
                {
                    startQ = [[SystemManager sharedManager].systemSettings.pEq3QFactor floatValue];
                }
                    break;
                    
                default:
                    break;
            }
        }
            //No break to handle the beginning scale too!
            //break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat newQ = startQ * (1 / scale);
            
            newQ = MAX(newQ, 0.2);
            newQ = MIN(newQ, 10.0);

            
            [self.filter event:@{@"action" : @"pinch",  @"qfactor" : [NSNumber numberWithFloat:newQ]}];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGFloat newQ = startQ * (1 / scale);
            
            newQ = MAX(newQ, 0.2);
            newQ = MIN(newQ, 10.0);
            
            [self changeQ:newQ fire:YES];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)onValueChanged:(id)sender
{
    CGFloat originlValue = ((UISlider*)sender).value;
    NSString* type = [self typeFromOption:self.segOptions.selectedSegmentIndex input:self.segInputType.selectedSegmentIndex];
    
    if(self.segInputType.selectedSegmentIndex == 1 || self.segInputType.selectedSegmentIndex == 2) {
        originlValue = originlValue / 10.0;
    }
    
    NSNumber* value = [NSNumber numberWithFloat:originlValue];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:type value:value completion:^(id completion) {
        
    }];
    
    [[SystemManager sharedManager] saveValueFrom:@{type : value} type:type];
    
    [self.lblValue value:value];
    
    [self updateGraph];
    
}

- (IBAction)onOptionChanged:(id)sender
{
    [self updateWithUserInfo:nil];
    [self updateGraph];
}

- (IBAction)onInputTypeChanged:(id)sender
{
    [self updateWithUserInfo:nil];
    [self updateGraph];
}

- (IBAction)onSwitch:(id)sender
{
    NSString* type = nil;
    
    switch (self.segOptions.selectedSegmentIndex) {
        case 0:
        {
            type = TAPDigitalSignalProcessingKeyPEQ1OnOff;
        }
            break;
        case 1:
        {
            type = TAPDigitalSignalProcessingKeyPEQ2OnOff;
        }
            break;
        case 2:
        {
            type = TAPDigitalSignalProcessingKeyPEQ3OnOff;
        }
            break;
            
        default:
            break;
    }
    
    NSNumber* value = [NSNumber numberWithBool:self.swOnOff.on];
    
    [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:type value:value completion:^(id completion) {
        
        
    }];
    
    [[SystemManager sharedManager] saveValueFrom:@{type : value} type:type];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self updateGraph];
    });
}

- (void)updateWithUserInfo:(NSDictionary *)userInfo
{
    BOOL on = NO;
    NSNumber* freq;
    NSNumber* boost;
    NSNumber* qfactor;
    
    //determine which PEQ is in use. take to value out
    switch (self.segOptions.selectedSegmentIndex) {
        case 0:
        {
            on = [[SystemManager sharedManager].systemSettings.pEq1OnOff boolValue];
            freq = [SystemManager sharedManager].systemSettings.pEq1Frequency;
            boost = [SystemManager sharedManager].systemSettings.pEq1Boost;
            qfactor = [SystemManager sharedManager].systemSettings.pEq1QFactor;
        }
            break;
        case 1:
        {
            on = [[SystemManager sharedManager].systemSettings.pEq2OnOff boolValue];
            freq = [SystemManager sharedManager].systemSettings.pEq2Frequency;
            boost = [SystemManager sharedManager].systemSettings.pEq2Boost;
            qfactor = [SystemManager sharedManager].systemSettings.pEq2QFactor;
        }
            break;
        case 2:
        {
            on = [[SystemManager sharedManager].systemSettings.pEq3OnOff boolValue];
            freq = [SystemManager sharedManager].systemSettings.pEq3Frequency;
            boost = [SystemManager sharedManager].systemSettings.pEq3Boost;
            qfactor = [SystemManager sharedManager].systemSettings.pEq3QFactor;
        }
            break;
            
        default:
            break;
    }
    
    //accomodate the value to the UI controls, except graph
    
    [self.swOnOff setOn:on];
    
    switch (self.segInputType.selectedSegmentIndex) {
        case 0:
        {
            //central frequecy
            self.lblInputType.text = @"Central Frequency";
            [ThemeUtils themeUnitLabel:self.lblValue unit:@"Hz"];
            self.lblValue.numberFormatter.maximumFractionDigits = 0;
            
            [self.lblValue value:freq];
            
            self.sliderValue.maximumValue = 200.0;
            self.sliderValue.minimumValue = 20.0;
            
            self.sliderValue.value = [freq floatValue];
            
        }
            break;
        case 1:
        {
            //boost
            self.lblInputType.text = @"Boost";
            [ThemeUtils themeUnitLabel:self.lblValue unit:@"dB"];
            self.lblValue.numberFormatter.minimumFractionDigits = 1;
            self.lblValue.numberFormatter.maximumFractionDigits = 1;
            self.lblValue.numberFormatter.minimumIntegerDigits = 1;
            
            [self.lblValue value:boost];
            
            self.sliderValue.maximumValue = 60.0;
            self.sliderValue.minimumValue = -120.0;
            
            self.sliderValue.value = [boost floatValue] * 10;
        }
            break;
        case 2:
        {
            //q factor
            self.lblInputType.text = @"Q Factor";
            [ThemeUtils themeUnitLabel:self.lblValue unit:@""];
            self.lblValue.numberFormatter.minimumFractionDigits = 1;
            self.lblValue.numberFormatter.maximumFractionDigits = 1;
            self.lblValue.numberFormatter.minimumIntegerDigits = 1;
            
            [self.lblValue value:qfactor];
            
            self.sliderValue.maximumValue = 100.0;
            self.sliderValue.minimumValue = 2.0;
            
            self.sliderValue.value = [qfactor floatValue] * 10;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ActionIntervalFilter

- (void)action:(NSDictionary *)userInfo
{
    
    NSString* action = [userInfo objectForKey:@"action"];
    
    if([action isEqualToString:@"pan"])
    {
        CGFloat freq = [[userInfo objectForKey:@"freq"] floatValue];
        CGFloat boost = [[userInfo objectForKey:@"boost"] floatValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self changeFreq:freq boost:boost fire:YES];
        });
        
    }else if([action isEqualToString:@"pinch"])
    {
        CGFloat q = [[userInfo objectForKey:@"qfactor"] floatValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self changeQ:q fire:YES];
        });
    }
    
}

- (void)filtered:(NSDictionary *)userInfo
{
    NSString* action = [userInfo objectForKey:@"action"];
    
    if([action isEqualToString:@"pan"])
    {
        CGFloat freq = [[userInfo objectForKey:@"freq"] floatValue];
        CGFloat boost = [[userInfo objectForKey:@"boost"] floatValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self changeFreq:freq boost:boost fire:NO];
        });
        
    }else if([action isEqualToString:@"pinch"])
    {
        CGFloat q = [[userInfo objectForKey:@"qfactor"] floatValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self changeQ:q fire:NO];
        });
    }
    
    
}

#pragma mark - Core Plot

- (void)setupGraph
{
    if(!self.graphHostingView)
    {
        self.graphHostingView = [[CPTGraphHostingView alloc] initWithFrame:self.hostView.bounds];
        [self.hostView addSubview:self.graphHostingView];
        
        self.graphHostingView.userInteractionEnabled = NO;
        
        self.plot = [[PEQPlot alloc] init];
        
        self.plot.selectedColor = kColorMain;
        self.plot.enableColour = [UIColor blackColor];
        self.plot.disableColor = [UIColor lightGrayColor];
        
        self.plot.selectedIndex = self.segOptions.selectedSegmentIndex;
        
        
        [self.plot renderInGraphHostingView:self.graphHostingView withTheme:nil animated:YES];
        
        [self updateGraph];
    }
}

- (void)updateGraph
{
    self.plot.selectedIndex = self.segOptions.selectedSegmentIndex;
    
    [self.plot.peqSettings removeAllObjects];
    
    NSDictionary* peq1 = @{@"on" : [SystemManager sharedManager].systemSettings.pEq1OnOff,
                           @"freq" : [SystemManager sharedManager].systemSettings.pEq1Frequency,
                           @"boost" : [SystemManager sharedManager].systemSettings.pEq1Boost,
                           @"qfactor" : [SystemManager sharedManager].systemSettings.pEq1QFactor};
    
    NSDictionary* peq2 = @{@"on" : [SystemManager sharedManager].systemSettings.pEq2OnOff,
                           @"freq" : [SystemManager sharedManager].systemSettings.pEq2Frequency,
                           @"boost" : [SystemManager sharedManager].systemSettings.pEq2Boost,
                           @"qfactor" : [SystemManager sharedManager].systemSettings.pEq2QFactor};
    
    NSDictionary* peq3 = @{@"on" : [SystemManager sharedManager].systemSettings.pEq3OnOff,
                           @"freq" : [SystemManager sharedManager].systemSettings.pEq3Frequency,
                           @"boost" : [SystemManager sharedManager].systemSettings.pEq3Boost,
                           @"qfactor" : [SystemManager sharedManager].systemSettings.pEq3QFactor};
    
    self.plot.peqSettings = [NSMutableArray arrayWithArray:@[peq1, peq2, peq3]];
    
    [self.plot updateGraph];
}

#pragma mark - helper methods

- (void)changeFreq:(CGFloat)freq boost:(CGFloat)boost fire:(BOOL)fire
{
    NSString* freqType;
    NSString* boostType;
    
    switch (self.segOptions.selectedSegmentIndex) {
            
        case 0:
        {
            [SystemManager sharedManager].systemSettings.pEq1Frequency = [NSNumber numberWithFloat:freq];
            [SystemManager sharedManager].systemSettings.pEq1Boost = [NSNumber numberWithFloat:boost];
            
            freqType = TAPDigitalSignalProcessingKeyEQ1Frequency;
            boostType = TAPDigitalSignalProcessingKeyEQ1Boost;
        }
            break;
        case 1:
        {
            [SystemManager sharedManager].systemSettings.pEq2Frequency = [NSNumber numberWithFloat:freq];
            [SystemManager sharedManager].systemSettings.pEq2Boost = [NSNumber numberWithFloat:boost];
            
            freqType = TAPDigitalSignalProcessingKeyEQ2Frequency;
            boostType = TAPDigitalSignalProcessingKeyEQ2Boost;
        }
            break;
        case 2:
        {
            [SystemManager sharedManager].systemSettings.pEq3Frequency = [NSNumber numberWithFloat:freq];
            [SystemManager sharedManager].systemSettings.pEq3Boost = [NSNumber numberWithFloat:boost];
            
            freqType = TAPDigitalSignalProcessingKeyEQ3Frequency;
            boostType = TAPDigitalSignalProcessingKeyEQ3Boost;
        }
            break;
            
        default:
            break;
    }
    
    if(fire)
    {
        [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:freqType value:[NSNumber numberWithFloat:freq] completion:^(id complete){
            
        }];
        
        [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:boostType value:[NSNumber numberWithFloat:boost] completion:^(id complete){
            
        }];
    }
    
    [self updateWithUserInfo:nil];
}

- (void)changeQ:(CGFloat)q fire:(BOOL)fire
{
    NSString* qType;

    switch (self.segOptions.selectedSegmentIndex) {
            
        case 0:
        {
            [SystemManager sharedManager].systemSettings.pEq1QFactor = [NSNumber numberWithFloat:q];
            qType = TAPDigitalSignalProcessingKeyEQ1QFactor;
        }
            break;
        case 1:
        {
            [SystemManager sharedManager].systemSettings.pEq2QFactor = [NSNumber numberWithFloat:q];
            qType = TAPDigitalSignalProcessingKeyEQ2QFactor;
        }
            break;
        case 2:
        {
            [SystemManager sharedManager].systemSettings.pEq3QFactor = [NSNumber numberWithFloat:q];
            qType = TAPDigitalSignalProcessingKeyEQ3QFactor;
        }
            break;
            
        default:
            break;
    }
    
    if(fire)
    {
        [[SystemManager sharedManager].dspService system:[SystemManager sharedManager].connectedSystem writeEqualizerType:qType value:[NSNumber numberWithFloat:q] completion:^(id complete){
            
        }];
    }
    
    [self updateWithUserInfo:nil];
}

- (NSString*)typeFromOption:(NSInteger)option input:(NSInteger)input
{
    NSString* type = nil;
    
    switch (input) {
        case 0:
        {
            //freq case
            type = [self frequencyTypeOfOption:option];
        }
            break;
        case 1:
        {
            //boost case
            type = [self boostTypeOfOption:option];
        }
            break;
        case 2:
        {
            //q factor case
            type = [self qFactorTypeOfOption:option];
        }
            break;
            
        default:
            break;
    }
    
    return type;
}

- (NSString*)frequencyTypeOfOption:(NSInteger)option
{
    NSString* type = nil;
    
    switch (option) {
        case 0:
        {
            type = TAPDigitalSignalProcessingKeyEQ1Frequency;
        }
            break;
        case 1:
        {
            type = TAPDigitalSignalProcessingKeyEQ2Frequency;
        }
            break;
        case 2:
        {
            type = TAPDigitalSignalProcessingKeyEQ3Frequency;
        }
            break;
            
        default:
            break;
    }
    
    return type;
}

- (NSString*)boostTypeOfOption:(NSInteger)option
{
    NSString* type = nil;
    
    switch (option) {
        case 0:
        {
            type = TAPDigitalSignalProcessingKeyEQ1Boost;
        }
            break;
        case 1:
        {
            type = TAPDigitalSignalProcessingKeyEQ2Boost;
        }
            break;
        case 2:
        {
            type = TAPDigitalSignalProcessingKeyEQ3Boost;
        }
            break;
            
        default:
            break;
    }
    
    return type;
}

- (NSString*)qFactorTypeOfOption:(NSInteger)option
{
    NSString* type = nil;
    
    switch (option) {
        case 0:
        {
            type = TAPDigitalSignalProcessingKeyEQ1QFactor;
        }
            break;
        case 1:
        {
            type = TAPDigitalSignalProcessingKeyEQ2QFactor;
        }
            break;
        case 2:
        {
            type = TAPDigitalSignalProcessingKeyEQ3QFactor;
        }
            break;
            
        default:
            break;
    }
    
    return type;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

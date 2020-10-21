//
//  EqualizerTableViewController.m
//  TADemo
//
//  Created by Lam Yick Hong on 6/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "EqualizerTableViewController.h"
#import "ParametricEqualizerTableViewController.h"
#import <TAPlatform/TAPSystem.h>

typedef NS_ENUM(NSInteger, Equalizer){
    EqualizerLowPassFilter = 0,
    EqualizerPhase,
    EqualizerPolarity,
    EqualizerPEQ,
    EqualizerRGC,
    EqualizerUnknown
};

@interface EqualizerTableViewController()

@property (nonatomic, strong)NSMutableDictionary* values;

@end

@implementation EqualizerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //initialize value
    
    self.title = @"Equalizer";
    
    //initalize services
    self.dspService = [[TAPDigitalSignalProcessingService alloc] initWithType:self.type];
    self.dspService.delegate = self;
    
    [self.dspService startMonitorEqualizerOfSystem:self.system];
    
    NSArray* keys = @[TAPDigitalSignalProcessingKeyLowPassOnOff,
                      TAPDigitalSignalProcessingKeyLowPassFrequency,
                      TAPDigitalSignalProcessingKeyLowPassSlope,
                      TAPDigitalSignalProcessingKeyPhase,
                      TAPDigitalSignalProcessingKeyPolarity,
                      TAPDigitalSignalProcessingKeyRGCOnOff,
                      TAPDigitalSignalProcessingKeyRGCFrequency,
                      TAPDigitalSignalProcessingKeyRGCSlope,
                      TAPDigitalSignalProcessingKeyTimeout,
                      TAPDigitalSignalProcessingKeyDisplay,
                      TAPDigitalSignalProcessingKeyStandby,
                      ];
    
    [self.dspService system:self.system targetKeys:keys equalizer:^(NSDictionary* equalizer, NSError* error){
       
        self.values = [[NSMutableDictionary alloc] initWithDictionary:equalizer];
        
        NSLog(@"%@", [self.values description]);
        
        [self reloadTable];
        
    }];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


#pragma mark - Table view delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case EqualizerLowPassFilter:
            return @"Lowpass Filter";
            break;
        case EqualizerPhase:
            return @"Phase";
            break;
        case EqualizerPolarity:
            return @"Polarity";
            break;
        case EqualizerPEQ:
            return @"Parametric EQ";
            break;
        case EqualizerRGC:
            return @"Room Gain Compression";
            break;
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return EqualizerUnknown;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case EqualizerLowPassFilter:
            return 4;
            break;
        case EqualizerPhase:
            return 2;
            break;
        case EqualizerPolarity:
            return 1;
            break;
        case EqualizerPEQ:
            return 1;
            break;
        case EqualizerRGC:
            return 3;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    // Configure the cell...
    switch ([indexPath section]) {
        case EqualizerLowPassFilter:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureSwitchTableCell" forIndexPath:indexPath];
                    
                    SwitchTableViewCell* switchCell = (SwitchTableViewCell*)cell;
                    switchCell.delegate = self;
                    switchCell.lblTitle.text = @"Low Pass Filter";
                    
                    switchCell.switchButton.on = [[self.values objectForKey:TAPDigitalSignalProcessingKeyLowPassOnOff] boolValue];
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Low Pass Frequency";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:TAPDigitalSignalProcessingKeyLowPassFrequency] integerValue]];
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = nil;
                    cell.detailTextLabel.text = nil;
                    
                    SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
                    sliderCell.delegate = self;
                    sliderCell.slider.minimumValue = 30;
                    sliderCell.slider.maximumValue = 200;
                    sliderCell.interval = 0.1;
                    
                    sliderCell.slider.value = [[self.values objectForKey:TAPDigitalSignalProcessingKeyLowPassFrequency] floatValue];
                }
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Slope";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:TAPDigitalSignalProcessingKeyLowPassSlope] integerValue]];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case EqualizerPhase:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Phase";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:TAPDigitalSignalProcessingKeyPhase] integerValue]];
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = nil;
                    cell.detailTextLabel.text = nil;
                    
                    SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
                    sliderCell.delegate = self;
                    sliderCell.slider.minimumValue = 0;
                    sliderCell.slider.maximumValue = 180;
                    sliderCell.interval = 0.1;
                    
                    sliderCell.slider.value = [[self.values objectForKey:TAPDigitalSignalProcessingKeyPhase] floatValue];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case EqualizerPolarity:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = @"Polarity";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:TAPDigitalSignalProcessingKeyPolarity] integerValue]];
            
        }
            break;
            
        case EqualizerPEQ:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = @"Parametric Equalizers";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
            break;
            
        case EqualizerRGC:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureSwitchTableCell" forIndexPath:indexPath];
                    
                    SwitchTableViewCell* switchCell = (SwitchTableViewCell*)cell;
                    switchCell.delegate = self;
                    switchCell.lblTitle.text = @"Room Gain Compression";
                    
                    switchCell.switchButton.on = [[self.values objectForKey:TAPDigitalSignalProcessingKeyRGCOnOff] boolValue];
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"RGC";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:TAPDigitalSignalProcessingKeyRGCFrequency] integerValue]];
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = nil;
                    cell.detailTextLabel.text = nil;
                    
                    SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
                    sliderCell.delegate = self;
                    sliderCell.slider.minimumValue = 25;
                    sliderCell.slider.maximumValue = 40;
                    sliderCell.interval = 0.1;
                    
                    sliderCell.slider.value = [[self.values objectForKey:TAPDigitalSignalProcessingKeyRGCFrequency] floatValue];
                }
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Slope";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:TAPDigitalSignalProcessingKeyRGCSlope] integerValue]];
                }
                    break;
                    
                default:
                    break;
            }
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case EqualizerLowPassFilter:
        {
            if([indexPath row] == 3)
            {
                NSNumber* currentNumber = [self.values objectForKey:TAPDigitalSignalProcessingKeyLowPassSlope];
                NSNumber* newNumber;
                NSInteger step = 6;
                NSInteger uppserLimit = 24;
                NSInteger lowerLimit = 6;
                
                NSInteger current = [currentNumber integerValue] + step;
                if(current > uppserLimit)
                {
                    current = lowerLimit;
                }
                
                newNumber = [NSNumber numberWithInteger:current];
                            
                [self updateType:TAPDigitalSignalProcessingKeyLowPassSlope value:newNumber];
            }
        }
            break;
          
        case EqualizerPolarity:
        {
            NSNumber* currentNumber = [self.values objectForKey:TAPDigitalSignalProcessingKeyPolarity];
            NSNumber* newNumber;
            
            if([currentNumber integerValue] == 1 )
            {
                newNumber = [NSNumber numberWithInteger:0];
                
            }else{
                
                newNumber = [NSNumber numberWithInteger:1];
            }
            
            [self updateType:TAPDigitalSignalProcessingKeyPolarity value:newNumber];
            
        }
            break;
            
        case EqualizerPEQ:
        {
            //TODO: go to PEQ
            [self performSegueWithIdentifier:@"EqualizerToPresetEqualizer" sender:self];
            
        }
            break;
   
            
        default:
            break;
    }
}

#pragma mark SliderTableViewCellDelegate method

- (void)cell:(SliderTableViewCell*)cell onValueChanged:(id)sender
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger value = (NSInteger)cell.slider.value;
    NSString* type = nil;
    
    switch ([indexPath section]) {
        case EqualizerLowPassFilter:
        {
            //only one slider cell, just assumpt it's frequency slider
            type = TAPDigitalSignalProcessingKeyLowPassFrequency;
        }
            break;
        case EqualizerPhase:
        {
            type = TAPDigitalSignalProcessingKeyPhase;
        }
            break;
        case EqualizerRGC:
        {
            type = TAPDigitalSignalProcessingKeyRGCFrequency;
        }
            break;
        default:
            break;
    }
    
    [self updateType:type value:[NSNumber numberWithInteger:value]];
}

#pragma mark SwitchTableViewCellDelegate method

- (void)cell:(SwitchTableViewCell*)cell onSwitchChanged:(id)sender
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    BOOL value = cell.switchButton.isOn;
    NSString* type = nil;
    
    switch ([indexPath section]) {
        case EqualizerLowPassFilter:
        {
            //only one switch cell, just assumpt it's on/off
            type = TAPDigitalSignalProcessingKeyLowPassOnOff;
        }
            break;
        case EqualizerRGC:
        {
            type = TAPDigitalSignalProcessingKeyRGCOnOff;
        }
        default:
            break;
    }
    
    [self updateType:type value:[NSNumber numberWithBool:value]];
    
}

#pragma mark TAPDigitalSignalProcessingServiceDelegate method

- (void)system:(id)system didUpdateEqualizer:(NSDictionary *)equalizer
{
    //self.values = [[NSMutableDictionary alloc] initWithDictionary:equalizer];
    
    NSLog(@"%@", [self.values description]);
    
    for (NSString* type in [equalizer allKeys])
    {
        [self.values setObject:[equalizer objectForKey:type] forKey:type];
    }
    
    [self reloadTable];
}

#pragma mark helper method

- (void)updateType:(NSString*)type value:(NSNumber*)number
{
    [self.dspService system:self.system writeEqualizerType:type value:number completion:^(id completion){
        
        [self.values setObject:number forKey:type];
        
        [self reloadTable];
    }];
}

- (void)reloadTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"EqualizerToPresetEqualizer"])
    {
        //pass on the connected system and also the systemService. you might want to have a singleton classes to store the service objects and else as an alternatives.
        ParametricEqualizerTableViewController* equalizerTableViewController = [segue destinationViewController];
        equalizerTableViewController.system = self.system;
        equalizerTableViewController.type = self.type;
        
    }
}

@end

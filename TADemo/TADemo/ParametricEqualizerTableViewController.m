//
//  ParametricEqualizerTableViewController.m
//  TADemo
//
//  Created by Lam Yick Hong on 9/7/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "ParametricEqualizerTableViewController.h"

@interface ParametricEqualizerTableViewController()

@property (nonatomic, strong)NSMutableDictionary* values;

@end

@implementation ParametricEqualizerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //initialize value
    
    self.title = @"Parametric Equalizer";
    
    //initalize services
    self.dspService = [[TAPDigitalSignalProcessingService alloc] initWithType:self.type];
    self.dspService.delegate = self;
    
    [self.dspService startMonitorEqualizerOfSystem:self.system];
    
    NSArray* keys = @[TAPDigitalSignalProcessingKeyPEQ1OnOff,
                      TAPDigitalSignalProcessingKeyEQ1Boost,
                      TAPDigitalSignalProcessingKeyEQ1Frequency,
                      TAPDigitalSignalProcessingKeyEQ1QFactor,
                      TAPDigitalSignalProcessingKeyPEQ2OnOff,
                      TAPDigitalSignalProcessingKeyEQ2Boost,
                      TAPDigitalSignalProcessingKeyEQ2Frequency,
                      TAPDigitalSignalProcessingKeyEQ2QFactor,
                      TAPDigitalSignalProcessingKeyPEQ3OnOff,
                      TAPDigitalSignalProcessingKeyEQ3Boost,
                      TAPDigitalSignalProcessingKeyEQ3Frequency,
                      TAPDigitalSignalProcessingKeyEQ3QFactor];
    
    [self.dspService system:self.system targetKeys:keys equalizer:^(NSDictionary* equalizer, NSError* error){
        
        self.values = [[NSMutableDictionary alloc] initWithDictionary:equalizer];
        
        NSLog(@"%@", [self.values description]);
        
        [self reloadTable];
        
    }];
    
}

#pragma mark - Table view delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //return [NSString stringWithFormat:@"PEQ %ld", section];
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    // Configure the cell...
    cell = [self tableViewCellForPEQAtIndexPath:indexPath];
    return cell;
}

#pragma mark SliderTableViewCellDelegate method

- (void)cell:(SliderTableViewCell*)cell onValueChanged:(id)sender
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    float value = (float)cell.slider.value;
    NSString* type = nil;
    
    switch ([indexPath section]) {
        case 0:
        {
            switch ([indexPath row]) {
                case 2:
                {
                    type = TAPDigitalSignalProcessingKeyEQ1Frequency;
                }
                    break;
                case 4:
                {
                    type = TAPDigitalSignalProcessingKeyEQ1Boost;
                }
                    break;
                case 6:
                {
                    type = TAPDigitalSignalProcessingKeyEQ1QFactor;
                    
                    value /= 10; // make it back to actual value to send
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch ([indexPath row]) {
                case 2:
                {
                    type = TAPDigitalSignalProcessingKeyEQ2Frequency;
                }
                    break;
                case 4:
                {
                    type = TAPDigitalSignalProcessingKeyEQ2Boost;
                }
                    break;
                case 6:
                {
                    type = TAPDigitalSignalProcessingKeyEQ2QFactor;
                    
                    value /= 10; // make it back to actual value to send
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch ([indexPath row]) {
                case 2:
                {
                    type = TAPDigitalSignalProcessingKeyEQ3Frequency;
                }
                    break;
                case 4:
                {
                    type = TAPDigitalSignalProcessingKeyEQ3Boost;
                }
                    break;
                case 6:
                {
                    type = TAPDigitalSignalProcessingKeyEQ3QFactor;
                    
                    value /= 10; // make it back to actual value to send
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    [self updateType:type value:[NSNumber numberWithFloat:value]];
}

#pragma mark SwitchTableViewCellDelegate method

- (void)cell:(SwitchTableViewCell*)cell onSwitchChanged:(id)sender
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    BOOL value = cell.switchButton.isOn;
    NSString* type = nil;
    
    switch ([indexPath section]) {
        case 0:
        {
            //only one switch cell, just assumpt it's on/off
            type = TAPDigitalSignalProcessingKeyPEQ1OnOff;
        }
            break;
        case 1:
        {
            //only one switch cell, just assumpt it's on/off
            type = TAPDigitalSignalProcessingKeyPEQ2OnOff;
        }
            break;
        case 2:
        {
            //only one switch cell, just assumpt it's on/off
            type = TAPDigitalSignalProcessingKeyPEQ3OnOff;
        }
            break;
        default:
            break;
    }
    
    [self updateType:type value:[NSNumber numberWithBool:value]];
}

#pragma mark TAPDigitalSignalProcessingServiceDelegate method

- (void)system:(id)system didUpdateEqualizer:(NSDictionary *)equalizer
{
    NSArray* allKeys = [equalizer allKeys];
    
    for(NSString* key in allKeys)
    {
        [self.values setObject:[equalizer objectForKey:key] forKey:key];        
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

- (UITableViewCell*)tableViewCellForPEQAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    NSString* onoff;
    NSString* title;
    
    NSString* freq;
    NSString* boost;
    NSString* qfactor;
    
    switch ([indexPath section]) {
        case 0:
        {
            onoff = TAPDigitalSignalProcessingKeyPEQ1OnOff;
            title = @"PEQ1";
            
            freq = TAPDigitalSignalProcessingKeyEQ1Frequency;
            boost = TAPDigitalSignalProcessingKeyEQ1Boost;
            qfactor = TAPDigitalSignalProcessingKeyEQ1QFactor;
        }
            break;
        case 1:
        {
            onoff = TAPDigitalSignalProcessingKeyPEQ2OnOff;
            title = @"PEQ2";
            
            freq = TAPDigitalSignalProcessingKeyEQ2Frequency;
            boost = TAPDigitalSignalProcessingKeyEQ2Boost;
            qfactor = TAPDigitalSignalProcessingKeyEQ2QFactor;
        }
            break;
        case 2:
        {
            onoff = TAPDigitalSignalProcessingKeyPEQ3OnOff;
            title = @"PEQ3";
            
            freq = TAPDigitalSignalProcessingKeyEQ3Frequency;
            boost = TAPDigitalSignalProcessingKeyEQ3Boost;
            qfactor = TAPDigitalSignalProcessingKeyEQ3QFactor;
        }
            break;
            
        default:
            break;
    }
    
    switch ([indexPath row]) {
        case 0:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"FeatureSwitchTableCell" forIndexPath:indexPath];
            
            SwitchTableViewCell* switchCell = (SwitchTableViewCell*)cell;
            switchCell.delegate = self;
            switchCell.lblTitle.text = title;
            
            switchCell.switchButton.on = [[self.values objectForKey:onoff] boolValue];
        }
            break;
        case 1:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = @"Frequency";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:freq] integerValue]];
        }
            break;
        case 2:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            
            SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
            sliderCell.delegate = self;
            sliderCell.slider.minimumValue = 200;
            sliderCell.slider.maximumValue = 2500;
            sliderCell.interval = 0.1;
            
            sliderCell.slider.value = [[self.values objectForKey:freq] floatValue];
        }
            break;
        case 3:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = @"Boost";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:boost] integerValue]];
        }
            break;
        case 4:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            
            SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
            sliderCell.delegate = self;
            sliderCell.slider.minimumValue = -120;
            sliderCell.slider.maximumValue = 60;
            sliderCell.interval = 0.1;
            
            sliderCell.slider.value = [[self.values objectForKey:boost] floatValue];
        }
            break;
        case 5:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = @"QFactor";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.values objectForKey:qfactor] integerValue]];
        }
            break;
        case 6:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            
            SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
            sliderCell.delegate = self;
            sliderCell.slider.minimumValue = 0;
            sliderCell.slider.maximumValue = 100; //range is 0.0 to 10.0, step 0.2
            sliderCell.interval = 0.1;
            
            sliderCell.slider.value = [[self.values objectForKey:qfactor] floatValue] * 10;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

@end

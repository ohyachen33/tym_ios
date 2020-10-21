//
//  FeatureTableViewController.m
//  TADemo
//
//  Created by Lam Yick Hong on 11/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "FeatureTableViewController.h"
#import "equalizerTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "constant.h"
#import <TAPlatform/TAPSystem.h>

typedef NS_ENUM(NSInteger, FeatureGroup){
    FeatureGroupDeviceInfo = 0,
    FeatureGroupBattery,
    FeatureGroupPlayControl,
    FeatureGroupAudioStatus,
    FeatureGroupPowerManagment,
    FeatureGroupVolume,
    FeatureGroupEQ,
    FeatureGroupTrueWireless,
    FeatureGroupSettings,
    FeatureGroupPresets,
    FeatureGroupUnknown
};

@interface FeatureTableViewController()

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* modelNumber;
@property(nonatomic, strong) NSString* serialNimber;
@property(nonatomic, strong) NSString* softwareVersion;
@property(nonatomic, strong) NSString* hardwareVersion;

@property(nonatomic, strong) NSString* batteryLevel;
@property(nonatomic, strong) NSString* volume;
@property(nonatomic, strong) NSMutableDictionary* settings;

@property TAPSystemServicePowerStatus powerStatus;
@property TAPPlayControlServicePlayStatus playbackStatus;
@property TAPPlayControlServiceAudioSource audioSource;
@property TAPPlayControlServiceANCStatus anc;
@property TAPPlayControlServiceTrueWirelessStatus trueWireless;

@property(nonatomic, strong) NSString* preset1Name;
@property(nonatomic, strong) NSString* preset2Name;
@property(nonatomic, strong) NSString* preset3Name;

@end

@implementation FeatureTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //initialize value
    self.name = nil;
    self.modelNumber = nil;
    self.serialNimber = nil;
    self.softwareVersion = nil;
    self.hardwareVersion = nil;
    
    self.batteryLevel = nil;
    self.volume = nil;
    
    self.title = [(CBPeripheral*)[(TAPSystem*)(self.system) instance] name];
    
    //initalize services
    self.playControlService = [[TAPPlayControlService alloc] initWithType:self.type];
    self.playControlService.delegate = self;

    [self fetchFromSystem];
    
    [self subscribeServices];
}

- (void)fetchFromSystem
{
    if([[self.model objectForKey:@"filename"] isEqualToString:kFilenameCSR1010])
    {
        [self.playControlService system:self.system volume:^(NSString* volume){
            
            self.volume = volume;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system settings:^(NSDictionary* settings, NSError* error){
            
            self.settings = [[NSMutableDictionary alloc] initWithDictionary:settings];
            
            NSLog(@"%@", [self.settings description]);
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system preset:@"1" name:^(NSString* presetName){
            
            self.preset1Name = presetName;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system preset:@"2" name:^(NSString* presetName){
            
            self.preset2Name = presetName;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system preset:@"3" name:^(NSString* presetName){
            
            self.preset3Name = presetName;
            
            [self reloadTable];
        }];
        
    }else if([[self.model objectForKey:@"filename"] isEqualToString:kFilenameCSR8670])
    {
        [self.playControlService system:self.system volume:^(NSString* volume){
            
            self.volume = volume;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system deviceName:^(NSString* name){
            
            self.name = name;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system modelNumber:^(NSString* version){
            
            self.modelNumber = version;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system serialNumber:^(NSString* version){
            
            self.serialNimber = version;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system softwareVersion:^(NSString* version){
            
            self.softwareVersion = version;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system hardwareVersion:^(NSString* version){
            
            self.hardwareVersion = version;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system batteryLevel:^(NSString* batteryLevel){
            
            self.batteryLevel = batteryLevel;
            
            [self reloadTable];
        }];
        
        [self.systemService system:self.system powerStatus:^(TAPSystemServicePowerStatus powerStatus){
            
            self.powerStatus = powerStatus;
            
            [self reloadTable];
        }];
        
        [self.playControlService system:self.system playStatus:^(TAPPlayControlServicePlayStatus playStatus){
            
            self.playbackStatus = playStatus;
            
            [self reloadTable];
        }];
        
        [self.playControlService system:self.system audioSource:^(TAPPlayControlServiceAudioSource audioSource){
            
            self.audioSource = audioSource;
            
            [self reloadTable];
        }];
        
        [self.playControlService system:self.system anc:^(TAPPlayControlServiceANCStatus ancStatus){
            
            self.anc = ancStatus;
            
            [self reloadTable];
        }];
        
        [self.playControlService system:self.system trueWireless:^(TAPPlayControlServiceTrueWirelessStatus trueWirelessStatus){
            
            self.trueWireless = trueWirelessStatus;
            
            [self reloadTable];
        }];
        
    }
}

- (void)subscribeServices
{
    if([[self.model objectForKey:@"filename"] isEqualToString:kFilenameCSR1010])
    {
        [self.playControlService startMonitorVolumeOfSystem:self.system];
        
    }else if([[self.model objectForKey:@"filename"] isEqualToString:kFilenameCSR8670])
    {
        [self.playControlService startMonitorVolumeOfSystem:self.system];
        [self.playControlService startMonitorPlayStatusOfSystem:self.system];
        [self.systemService startMonitorPowerStatusOfSystem:self.system];
    }
}

#pragma mark - Table view delegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case FeatureGroupDeviceInfo:
            return @"Device Info";
            break;
        case FeatureGroupBattery:
            return @"Battery";
            break;
        case FeatureGroupPlayControl:
            return @"Play Control";
            break;
        case FeatureGroupAudioStatus:
            return @"Audio Status";
            break;
        case FeatureGroupPowerManagment:
            return @"Power Management";
            break;
        case FeatureGroupVolume:
            return @"Volume";
            break;
        case FeatureGroupEQ:
            return @"Equalizer";
            break;
        case FeatureGroupTrueWireless:
            return @"TrueWireless";
            break;
        case FeatureGroupSettings:
            return @"Settings";
        case FeatureGroupPresets:
            return @"Presets";
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return FeatureGroupUnknown;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if([[self.model objectForKey:@"filename"] isEqualToString:kFilenameCSR1010])
    {
        switch (section) {
            case FeatureGroupDeviceInfo:
                return 1;
                break;
            case FeatureGroupBattery:
                return 1;
                break;
            case FeatureGroupPlayControl:
                return 0;
                break;
            case FeatureGroupAudioStatus:
                return 0;
                break;
            case FeatureGroupPowerManagment:
                return 0;
                break;
            case FeatureGroupVolume:
                return 4;
                break;
            case FeatureGroupEQ:
                return 1;
                break;
            case FeatureGroupTrueWireless:
                return 0;
                break;
            case FeatureGroupSettings:
                return 3;
                break;
            case FeatureGroupPresets:
                return 3;
                break;
            default:
                break;
        }
        
        
    }else if([[self.model objectForKey:@"filename"] isEqualToString:kFilenameCSR8670])
    {
        switch (section) {
            case FeatureGroupDeviceInfo:
                return 5;
                break;
            case FeatureGroupBattery:
                return 1;
                break;
            case FeatureGroupPlayControl:
                return 4;
                break;
            case FeatureGroupAudioStatus:
                return 3;
                break;
            case FeatureGroupPowerManagment:
                return 4;
                break;
            case FeatureGroupVolume:
                return 1;
                break;
            case FeatureGroupEQ:
                return 0;
                break;
            case FeatureGroupTrueWireless:
                return 2;
                break;
            case FeatureGroupSettings:
                return 0;
                break;
            case FeatureGroupPresets:
                return 0;
                break;
            default:
                break;
        }
        
    }
    
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    // Configure the cell...
    switch ([indexPath section]) {
        case FeatureGroupDeviceInfo:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Software Version";
                    cell.detailTextLabel.text = [self featureValueInString:self.softwareVersion];
         
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Model Number";
                    cell.detailTextLabel.text = [self featureValueInString:self.modelNumber];
                    
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Serial Number";
                    cell.detailTextLabel.text = [self featureValueInString:self.serialNimber];
                    
                }
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Hardware Version";
                    cell.detailTextLabel.text = [self featureValueInString:self.hardwareVersion];
                    
                }
                    break;
                case 4:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Device Name";
                    cell.detailTextLabel.text = [self featureValueInString:self.name];
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case FeatureGroupBattery:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Battery Level";
                    cell.detailTextLabel.text = [self featureValueInString:self.batteryLevel];
                    
                }
                    break;

                default:
                    break;
            }
            
        }
            break;
        case FeatureGroupPlayControl:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Play";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Pause";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Previous";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Next";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case FeatureGroupAudioStatus:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Current Audio Source";
                    cell.detailTextLabel.text = [self audioSourceDescription:self.audioSource];
                    
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Playback Status";
                    cell.detailTextLabel.text = [self playStatusDescription:self.playbackStatus];
                    
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"ANC";
                    cell.detailTextLabel.text = [self ancDescription:self.anc];
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case FeatureGroupPowerManagment:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Completely Off";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"On";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Standby Low";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Standby High";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                default:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Unknown";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
            }
            
            if((NSInteger)self.powerStatus == [indexPath row])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
        case FeatureGroupVolume:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Current Volume";
                    cell.detailTextLabel.text = [self featureValueInString:self.volume];
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Volume Up";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = @"Volume Down";
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 3:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SliderTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = nil;
                    cell.detailTextLabel.text = nil;
                    
                    SliderTableViewCell* sliderCell = (SliderTableViewCell*)cell;
                    sliderCell.delegate = self;
                    sliderCell.slider.minimumValue = -60;
                    sliderCell.slider.maximumValue = 0;
                    sliderCell.interval = 0.1;
                    
                    if(self.volume){
                        sliderCell.slider.value = [self.volume floatValue];
                    }                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case FeatureGroupTrueWireless:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Status";
                    cell.detailTextLabel.text = [self trueWirelessDescription:self.trueWireless];
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Send Command";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case FeatureGroupEQ:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
            
            cell.textLabel.text = @"Equalizer";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
            break;
        case FeatureGroupPresets:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = self.preset1Name;
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = self.preset2Name;
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureTableCell" forIndexPath:indexPath];
                    cell.textLabel.text = self.preset3Name;
                    cell.detailTextLabel.text = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case  FeatureGroupSettings:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Display";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.settings objectForKey:TAPSystemKeyDisplay] integerValue]];
                }
                    break;
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Standby";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.settings objectForKey:TAPSystemKeyStandby] integerValue]];
                }
                    break;
                case 2:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FeatureDetailTableCell" forIndexPath:indexPath];
                    
                    cell.textLabel.text = @"Timeout";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [[self.settings objectForKey:TAPSystemKeyTimeout] integerValue]];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case FeatureGroupDeviceInfo:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        
        case FeatureGroupPlayControl:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    [self.playControlService system:self.system play:^(TAPPlayControlServicePlayStatus status){
                        
                    }];
                    
                }
                    break;
                case 1:
                {
                    [self.playControlService system:self.system pause:^(TAPPlayControlServicePlayStatus status){
                        
                    }];
                }
                    break;
                case 2:
                {
                    [self.playControlService system:self.system previous:^(id status){
                        
                    }];
                }
                case 3:
                {
                    [self.playControlService system:self.system next:^(id status){
                        
                    }];
                }
                    break;
            }
        }
            break;
            
        case FeatureGroupPowerManagment:
        {
            TAPSystemServicePowerStatus powerStatus = [indexPath row];
            [self.systemService system:self.system turnPowerStatus:powerStatus completion:^(id complete){
                
                //re-fetch the status
                [self.systemService system:self.system powerStatus:^(TAPSystemServicePowerStatus powerStatus){
                    
                    self.powerStatus = powerStatus;
                    
                    [self reloadTable];
                }];
                
            }];
            
        }
            break;
            
        case FeatureGroupAudioStatus:
        {
            //tap on ANC
            if ([indexPath row] == 2)
            {
                TAPPlayControlServiceANCStatus target;
                
                if(self.anc == TAPPlayControlServiceANCStatusOn)
                {
                    target = TAPPlayControlServiceANCStatusOff;
                    
                }else{
                    
                    target = TAPPlayControlServiceANCStatusOn;
                }
                
                [self.playControlService system:self.system turnANC:target completion:^(id complete){
                    
                    self.anc = target;
                    
                    [self reloadTable];
                }];
            }
        }
            break;
            
        case FeatureGroupVolume:
        {
            switch ([indexPath row]) {
                case 1:
                {
                    [self.playControlService volumeUpSystem:self.system completion:^(id complete){
                        NSLog(@"Volume up to connected system");
                    }];
                }
                    break;
                case 2:
                {
                    [self.playControlService volumeDownSystem:self.system completion:^(id complete){
                        NSLog(@"Volume down to connected system");
                    }];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case FeatureGroupTrueWireless:
        {
            if([indexPath row] == 1)
            {
                switch (self.trueWireless) {
                    case TAPPlayControlServiceTrueWirelessStatusDisconnected:
                    {
                        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"TrueWireless" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Connect as Master", @"Connect as Slave", nil];
                        
                        [actionSheet showInView:self.view];
                    }
                     
                        break;
                        
                    case TAPPlayControlServiceTrueWirelessStatusConnectedMaster:
                    case TAPPlayControlServiceTrueWirelessStatusConnectedSlave:
                    {
                        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"TrueWireless" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Disconnet", nil];
                        
                        [actionSheet showInView:self.view];
                    }
                        
                        break;
                        
                        
                    default:
                        break;
                }
            }
            break;
        }
        case FeatureGroupEQ:
        {
            [self performSegueWithIdentifier:@"FeatureToEqualizer" sender:nil];
        }
            break;
        case FeatureGroupSettings:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    NSNumber* currentNumber = [self.settings objectForKey:TAPSystemKeyDisplay];
                    NSNumber* newNumber;
                    NSInteger step = 1;
                    NSInteger uppserLimit = 2;
                    NSInteger lowerLimit = 0;
                    
                    NSInteger current = [currentNumber integerValue] + step;
                    if(current > uppserLimit)
                    {
                        current = lowerLimit;
                    }
                    
                    newNumber = [NSNumber numberWithInteger:current];
                    
                    [self updateSettingsType:TAPSystemKeyDisplay value:newNumber];
                }
                    break;
                case 1:
                {
                    NSNumber* currentNumber = [self.settings objectForKey:TAPSystemKeyStandby];
                    NSNumber* newNumber;
                    NSInteger step = 1;
                    NSInteger uppserLimit = 2;
                    NSInteger lowerLimit = 0;
                    
                    NSInteger current = [currentNumber integerValue] + step;
                    if(current > uppserLimit)
                    {
                        current = lowerLimit;
                    }
                    
                    newNumber = [NSNumber numberWithInteger:current];
                    
                    [self updateSettingsType:TAPSystemKeyStandby value:newNumber];
                }
                    break;
                case 2:
                {
                    NSNumber* currentNumber = [self.settings objectForKey:TAPSystemKeyTimeout];
                    NSNumber* newNumber;
                    NSInteger step = 10;
                    NSInteger uppserLimit = 60;
                    NSInteger lowerLimit = 10;
                    
                    NSInteger current = [currentNumber integerValue] + step;
                    if(current > uppserLimit)
                    {
                        current = lowerLimit;
                    }
                    
                    newNumber = [NSNumber numberWithInteger:current];
                    
                    [self updateSettingsType:TAPSystemKeyTimeout value:newNumber];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case FeatureGroupPresets:
        {
            
            UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Preset" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Load", @"Save", @"Edit Name", nil];
            
            [actionSheet showInView:self.view];
            
        }
            
        default:
            break;
    }
}

#pragma mark TAPSystemServiceDelegate

- (void)didUpdateState:(TAPSystemServiceState)state
{
    switch (state) {
        case TAPSystemServiceStateReady:
        {
            NSLog(@"System Serivce is ready to scan.");
            
            
        }
            break;
            
        case TAPSystemServiceStateOff:
        case TAPSystemServiceStateUnsupported:
        case TAPSystemServiceStateUnauthorized:
        {
            NSLog(@"System Serivce can't be used.");
            
            //TODO: disable the UI?
        }
            break;
            
        default:
            break;
    }
}

#pragma mark UIActionSheetDelegate method

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath* selectedRow = [self.tableView indexPathForSelectedRow];
    
    switch ([selectedRow section]) {
        case FeatureGroupTrueWireless:
        {
            switch ([selectedRow row]) {
                case TAPPlayControlServiceTrueWirelessStatusDisconnected:
                {
                    TAPPlayControlServiceTrueWirelessCommand command = TAPPlayControlServiceTrueWirelessCommandPairingMaster;
                    
                    if(buttonIndex == 1)
                    {
                        command = TAPPlayControlServiceTrueWirelessCommandPairingSlave;
                    }
                    
                    [self.playControlService system:self.system configTrueWireless:command completion:^(id complete){
                        
                        //re-fetch the status
                        [self.playControlService system:self.system trueWireless:^(TAPPlayControlServiceTrueWirelessStatus trueWirelessStatus){
                            
                            self.trueWireless = trueWirelessStatus;
                            
                            [self reloadTable];
                        }];
                        
                    }];
                }
                    break;
                case TAPPlayControlServiceTrueWirelessStatusConnectedMaster:
                case TAPPlayControlServiceTrueWirelessStatusConnectedSlave:
                {
                    if(buttonIndex == 0)
                    {
                        [self.playControlService system:self.system configTrueWireless:TAPPlayControlServiceTrueWirelessCommandPairingMaster completion:^(id complete){
                            
                            //re-fetch the status
                            [self.playControlService system:self.system trueWireless:^(TAPPlayControlServiceTrueWirelessStatus trueWirelessStatus){
                                
                                self.trueWireless = trueWirelessStatus;
                                
                                [self reloadTable];
                            }];
                        }];
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case FeatureGroupPresets:
        {
            NSString* presetId;
            
            switch ([selectedRow row]) {
                case 0:
                {
                    presetId = @"1";
                }
                    break;
                case 1:
                {
                    presetId = @"2";
                }
                    break;
                case 2:
                {
                    presetId = @"3";
                }
                    break;
            }
            
            if(buttonIndex == 0)
            {
                //load
                [self.systemService system:self.system loadToCurrentFromPreset:presetId completion:^(id complete){
                    
                    [self reloadTable];
                }];
                
            }else if(buttonIndex == 1)
            {
                //save
                [self.systemService system:self.system saveCurrentToPreset:presetId completion:^(id complete){
                    
                    [self reloadTable];
                }];
                
            }if(buttonIndex == 2)
            {
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"HH mm ss"];
                NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
                
                //modify name
                [self.systemService system:self.system preset:presetId writeName:dateString completion:^(id complete){
                    
                }];
            }
            
        }
            break;
            
        default:
            break;
    }

    
    
}

#pragma mark SliderTableViewCellDelegate method

- (void)cell:(SliderTableViewCell*)cell onValueChanged:(id)sender
{
    NSInteger volume = (NSInteger)cell.slider.value;
    
    [self.playControlService system:self.system writeVolume:volume completion:^(id completion){

        self.volume = [NSString stringWithFormat:@"%ld", volume];
        
        NSLog(@"### Write Volume - %@", self.volume);
        
        [self reloadTable];
    }];
}

#pragma mark TAPSystemServiceDelegate method

- (void)system:(id)system didUpdatePowerStatus:(TAPSystemServicePowerStatus)status
{
    self.powerStatus = status;
    
    [self reloadTable];
}

#pragma mark TAPPlayControlServiceDelegate method

- (void)system:(id)system didUpdateVolume:(NSString*)volume
{
    self.volume = volume;
    
    [self reloadTable];
}

- (void)system:(id)system didUpdatePlayStatus:(TAPPlayControlServicePlayStatus)status
{
    self.playbackStatus = status;
    [self reloadTable];
}

- (void)system:(id)system didUpdateAudioSource:(TAPPlayControlServiceAudioSource)audioSource
{
    self.audioSource = audioSource;
    [self reloadTable];
}

#pragma mark helper method

- (void)reloadTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSString*)featureValueInString:(NSString*)valueString
{
    if(!valueString)
    {
        return @"N/A";
    }
    
    return valueString;
}

- (NSString*)playStatusDescription:(TAPPlayControlServicePlayStatus)status
{
    NSString* valueString = @"Unknown";
    
    switch (status) {
        case TAPPlayControlServicePlayStatusPause:
            valueString = @"Paused";
            break;
        case TAPPlayControlServicePlayStatusPlay:
            valueString = @"Playing";
            break;
        case TAPPlayControlServicePlayStatusStopped:
            valueString = @"Stopped";
            break;
            
        default:
            break;
    }
    
    return valueString;
}

- (NSString*)audioSourceDescription:(TAPPlayControlServiceAudioSource)source
{
    NSString* valueString = @"Unknown";
    
    switch (source) {
        case TAPPlayControlServiceAudioSourceNoSource:
            valueString = @"No Source";
            break;
        case TAPPlayControlServiceAudioSourceBluetooth:
            valueString = @"Bluetooth";
            break;
        case TAPPlayControlServiceAudioSourceAuxIn:
            valueString = @"Aux In";
            break;
        case TAPPlayControlServiceAudioSourceUSB:
            valueString = @"USB";
            break;
            
        default:
            break;
    }
    
    return valueString;
}

- (NSString*)ancDescription:(TAPPlayControlServiceANCStatus)anc
{
    NSString* valueString = @"Unknown";
    
    switch (anc) {
        case TAPPlayControlServiceANCStatusOn:
            valueString = @"on";
            break;
        case TAPPlayControlServiceANCStatusOff:
            valueString = @"off";
            break;
            
        default:
            break;
    }
    
    return valueString;
}

- (NSString*)trueWirelessDescription:(TAPPlayControlServiceTrueWirelessStatus)trueWireless
{
    NSString* valueString = @"Unknown";
    
    switch (trueWireless) {
        case TAPPlayControlServiceTrueWirelessStatusDisconnected:
            valueString = @"Disconnected";
            break;
        case TAPPlayControlServiceTrueWirelessStatusReconnecting:
            valueString = @"Reconnecting";
            break;
        case TAPPlayControlServiceTrueWirelessStatusPairingMaster:
            valueString = @"Pairing as Master";
            break;
        case TAPPlayControlServiceTrueWirelessStatusPairingSlave:
            valueString = @"Pairing as Slave";
            break;
        case TAPPlayControlServiceTrueWirelessStatusConnectedMaster:
            valueString = @"Connected as Master";
            break;
        case TAPPlayControlServiceTrueWirelessStatusConnectedSlave:
            valueString = @"Connected as Slave";
            break;
            
        default:
            break;
    }
    
    return valueString;
}

- (void)updateSettingsType:(NSString*)type value:(NSNumber*)number
{
    [self.systemService system:self.system writeSettingsType:type value:number completion:^(id completion){
        
        [self.settings setObject:number forKey:type];
        
        [self reloadTable];
    }];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"FeatureToEqualizer"])
    {
        //pass on the connected system and also the systemService. you might want to have a singleton classes to store the service objects and else as an alternatives.
        EqualizerTableViewController* equalizerTableViewController = [segue destinationViewController];
        equalizerTableViewController.system = self.system;
        equalizerTableViewController.type = self.type;
        
    }
}

@end

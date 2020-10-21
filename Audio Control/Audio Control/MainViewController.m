//
//  MenuViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 5/11/2015.
//  Copyright © 2015 Tymphany. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "MainViewController.h"
#import "PannableViewController.h"
#import "PedalCaseViewController.h"
#import "PopTableViewController.h"
#import "ThemeUtils.h"
#import "SystemManager.h"


enum{
    GroupConnect = 0,
    GroupFeatures,
    GroupSettings,
    GroupTotalCount
};

enum{
//    FeaturesFeatures = 0,
//    FeaturesControl,
    FeaturesControl = 0,
//    FeaturesWireless,
    FeaturesVoiceControl,
    
    FeaturesTotalCount
};

enum{
//    SettingsSettings = 0,
//    SettingsAbout,
    SettingsAbout = 0,
    SettingsTotalCount
};

typedef NSInteger Features;

@interface MainViewController ()

@property (nonatomic, strong)NSArray* menuItemTitles;
@property (nonatomic, strong)PedalCaseViewController* pedalCaseViewController;
@property (nonatomic, strong)PopTableViewController* discoverListViewController;
@property (nonatomic, strong)id deviceObserver;
@property (nonatomic, strong)id connectionObserver;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItemTitles = @[@[@"Connectivity"], @[@"Control",@"Voice Control"],@[@"About"]];
    
    self.deviceObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SystemDiscoveredNewSystem object:nil queue:nil usingBlock:^(NSNotification* note){
        
        if(self.discoverListViewController)
        {
            NSMutableArray* deviceNameList = [[NSMutableArray alloc] init];
            NSArray* devices = [SystemManager sharedManager].discoveredSystems;
            
            for (TAPSystem* system in devices)
            {
                [deviceNameList addObject:((CBPeripheral*)[system instance]).name];
            }
            
            [self.discoverListViewController updateItems:deviceNameList];
        }
    }];
    
    
    self.connectionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SystemStateDidUpdate object:nil queue:nil usingBlock:^(NSNotification* note){
        
        [self.tableView reloadData];
    }];
    
    
    
    
    [ThemeUtils roundCorner:self.view];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!self.pedalCaseViewController)
    {
        self.pedalCaseViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"PedalCaseViewController"];
        [self.view.superview addSubview:self.pedalCaseViewController.view];
        
        [self.pedalCaseViewController addPedalViewControllerByString:@"ControlViewController"];
        
        [self.pedalCaseViewController panAway];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.deviceObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.connectionObserver];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    switch (section) {
        case GroupConnect:
        {
            title = @"Bluetooth Low Energy";
        }
            break;
        case GroupFeatures:
        {
            title = @"Features";
        }
            break;
        case GroupSettings:
        {
            title = @"Settings";
        }
            break;
            
        default:
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger total = 0;
    
    switch (section) {
        case GroupConnect:
        {
            total = 1;
        }
            break;
        case GroupFeatures:
        {
            total = FeaturesTotalCount;
        }
            break;
        case GroupSettings:
        {
            total = SettingsTotalCount;
        }
            
        default:
            break;
    }
    
    return total;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    
    // Configure the cell...
    
    switch ([indexPath section]) {
        case GroupConnect:
        {
            cell.textLabel.font = [UIFont systemFontOfSize:15 weight:2.0];
            
            switch ([SystemManager sharedManager].state) {
                case SystemBLEStateScanning:
                {
                    cell.textLabel.text = [[self.menuItemTitles objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
                    cell.textLabel.textColor = [UIColor blueColor];
                }
                    break;
                    
                case SystemBLEStateConnected:
                {
                    CBPeripheral* peripheral = [[SystemManager sharedManager].connectedSystem instance];
                    
                    NSString* statusDescription = @"Connected";
                    NSString* fullString = [NSString stringWithFormat:@"%@ - %@", [peripheral name], statusDescription];
                    NSRange statusRange = [fullString rangeOfString:statusDescription];
                    
                    NSShadow* shadow = [[NSShadow alloc] init];
                    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
                    shadow.shadowColor = [UIColor grayColor];
                    shadow.shadowBlurRadius = 1.0;
                    
                    //attributing status
                    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
                    [attributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} range:statusRange];
                    [attributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} range:statusRange];
                    [attributedString addAttributes:@{NSShadowAttributeName : shadow} range:statusRange];
                    
                    cell.textLabel.attributedText = attributedString;
                }
                    break;
                case SystemBLEStateStopped:
                {
                    cell.textLabel.textColor = [UIColor grayColor];
                    cell.textLabel.text = @"Not Running";
                }
                    break;
                    
                default:
                    break;
            }        }
            break;
            
        case GroupFeatures:
        {
            cell.textLabel.text = [[self.menuItemTitles objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        }
            break;
        case GroupSettings:
        {
            cell.textLabel.text = [[self.menuItemTitles objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        }
            break;
        default:
            break;
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* deviceNameList = [[NSMutableArray alloc] init];
    NSArray* devices = [SystemManager sharedManager].discoveredSystems;

    switch ([indexPath section]) {
        case GroupConnect:
        {
            for (TAPSystem* system in devices)
            {
                [deviceNameList addObject:((CBPeripheral*)[system instance]).name];
            }
            
            self.discoverListViewController = [[PopTableViewController alloc] initWithTitle:@"Discovered Devices" items:deviceNameList];
            [self.discoverListViewController show: ^(NSInteger selectedIndex){
                
                if(selectedIndex >= 0)
                {
                    [[SystemManager sharedManager].systemService connectSystem:[devices objectAtIndex:selectedIndex]];
                }
                
            }];
        }
            break;
        case GroupFeatures:
        {
            switch ([indexPath row]) {
                    
//                case FeaturesFeatures:
//                {
//                    [self.pedalCaseViewController addPedalViewControllerByString:@"VolumePedalViewController"];
//                    [self.pedalCaseViewController panBack];
//                }
//                    break;
                case FeaturesControl:
                {
                    [self.pedalCaseViewController addPedalViewControllerByString:@"ControlViewController"];
                    [self.pedalCaseViewController panBack];
                }
                    break;
//                case FeaturesWireless:
//                {
//                    [self.pedalCaseViewController addPedalViewControllerByString:@"PhasePedalViewController"];
//                    [self.pedalCaseViewController panBack];
//                }
//                    break;
                case FeaturesVoiceControl:
                {
                    [self.pedalCaseViewController addPedalViewControllerByString:@"VioceControlViewController"];
                    [self.pedalCaseViewController panBack];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case GroupSettings:
        {
            switch ([indexPath row]) {
//                case SettingsSettings:
//                {
//                    [self.pedalCaseViewController addPedalViewControllerByString:@"SettingsViewController"];
//                    [self.pedalCaseViewController panBack];
//                }
//                    break;
            
                case SettingsAbout:
                {
                    [self.pedalCaseViewController addPedalViewControllerByString:@"AboutViewController"];
                    [self.pedalCaseViewController panBack];
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
    
}
#pragma mark - shake

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"Shake began");
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"Shake ended");
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"shake" object:nil];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    NSLog(@"shake cancelled");
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Helper

- (UIImage*)snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copied;
}
@end

//
//  DiscoveryTableViewController.m
//  TADemo
//
//  Created by Lam Yick Hong on 11/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//
#import <TAPlatform/TAPSystem.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "DiscoveryTableViewController.h"
#import "FeatureTableViewController.h"
#import "FilterTableViewController.h"

typedef NS_ENUM(NSInteger, DiscoverySortType){
    DiscoverySortTypeNone = 0,
    DiscoverySortTypeName,
    DiscoverySortTypeRSSI
};

@interface DiscoveryTableViewController ()<FilterTableViewControllerDelegate>

@property (strong, nonatomic) TAPSystemService *systemService;
@property (strong, nonatomic) NSMutableArray* systems;
@property (strong, nonatomic) NSString* type;
@property (nonatomic) DiscoverySortType sortType;

@property (assign, nonatomic) BOOL shouldFilter;
@property (assign, nonatomic) double filterLow;
@property (assign, nonatomic) double filterHigh;

@property (strong, nonatomic) id connectedSystem;

@end

@implementation DiscoveryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    self.title = [self.model objectForKey:@"title"];
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sortButton setTitle:@"Sort" forState:UIControlStateNormal];
    [sortButton addTarget:self action:@selector(sort) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sortItem  = [[UIBarButtonItem alloc] initWithCustomView:sortButton];

    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterItem  = [[UIBarButtonItem alloc] initWithCustomView:filterButton];

    self.navigationItem.rightBarButtonItems = @[filterItem, sortItem];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *filterSettings = [defaults objectForKey:@"FilterTableViewControllerSettings"];
    NSNumber *filterIsOn = filterSettings[@"filterIsOn"];
    if ([filterIsOn boolValue] == YES) {
        self.shouldFilter = YES;
        
        self.filterLow = [filterSettings[@"filterLow"] doubleValue];
        self.filterHigh = [filterSettings[@"filterHigh"] doubleValue];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    NSDictionary* serviceInfo;
    
    //retrieve the service info plist
    NSString *defaultFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:[self.model objectForKey:@"filename"] ofType:@"plist"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:defaultFilePath])
    {
        serviceInfo = [NSDictionary dictionaryWithContentsOfFile:defaultFilePath];
    }
    
    //TODO: Please revisit this type mechanism.
    self.type = [NSString stringWithFormat:@"BLE-%@", [self.model objectForKey:@"filename"]];
    
    self.systemService = [[TAPSystemService alloc] initWithType:self.type config:@{@"serviceInfo" : serviceInfo} delegate:self];
    self.systems = [[NSMutableArray alloc] init];
    
    if(self.connectedSystem)
    {
        [self.systemService disconnectSystem:self.connectedSystem];
        self.connectedSystem = nil;
    }
    
    [self.systemService scanForSystemsWithOptions:@{@"CBCentralManagerScanOptionAllowDuplicatesKey":@YES}];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    self.systemService.delegate = nil;
    
    [self.systems removeAllObjects];
    [self.systemService stopScanForSystems];
}

- (void)sort
{
    NSArray *sortArray = [self.systems sortedArrayUsingComparator:^NSComparisonResult(NSArray * _Nonnull obj1, NSArray *  _Nonnull obj2) {
        NSNumber *RSSI = obj1[1];
        NSNumber *anotherRSSI = obj2[1];
        
        if (RSSI > anotherRSSI) {
            return NSOrderedDescending;
        }else if (RSSI == anotherRSSI){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
        
    }];
    self.systems = [NSMutableArray arrayWithArray:sortArray];
    [self.tableView reloadData];
}

- (void)filter
{
    FilterTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterTableViewController"];
    vc.filterIsOn = self.shouldFilter;
    vc.left = self.filterLow;
    vc.right = self.filterHigh;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - FilterTableViewControllerDelegate
- (void)didSetFilter:(BOOL)isOn from:(double)left to:(double)right
{
    self.shouldFilter = isOn;
    if (isOn) {
        self.filterLow = left;
        self.filterHigh = right;
    }
    [self.tableView reloadData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *filterSettings = [NSMutableDictionary new];
    [filterSettings setObject:[NSNumber numberWithBool:isOn] forKey:@"filterIsOn"];
    if (isOn) {
        [filterSettings setObject:[NSNumber numberWithDouble:left] forKey:@"filterLow"];
        [filterSettings setObject:[NSNumber numberWithDouble:right] forKey:@"filterHigh"];
    }
    [defaults setObject:filterSettings forKey:@"FilterTableViewControllerSettings"];
    [defaults synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.systems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoveryTableCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    CBPeripheral* system = [[self.systems objectAtIndex:[indexPath row]][0] instance];
    NSNumber *RSSI = [self.systems objectAtIndex:[indexPath row]][1];
    
    if (self.shouldFilter) {
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:[system name]];

        NSAttributedString *rssiStr;
        if ([RSSI doubleValue] >= self.filterLow && [RSSI doubleValue] <= self.filterHigh) {
            rssiStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"      %@          PASS", RSSI] attributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}];

        }else{
            rssiStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"      %@          FAIL", RSSI] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];

        }
        [attributedStr appendAttributedString:rssiStr];
        cell.textLabel.attributedText = attributedStr;
        
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@       %@", [system name], RSSI];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAPSystem* system = [self.systems objectAtIndex:[indexPath row]][0];
    [self.systemService connectSystem:system];
}

#pragma mark TAPSystemServiceDelegate

- (void)didUpdateState:(TAPSystemServiceState)state
{
    switch (state) {
        case TAPSystemServiceStateReady:
        {
            NSLog(@"System Serivce is ready to rock.");
            [self.systemService scanForSystemsWithOptions:@{@"CBCentralManagerScanOptionAllowDuplicatesKey":@YES}];
        }
            break;
            
        default:
            break;
    }
}

- (void)didDiscoverSystem:(id)system RSSI:(NSNumber *)RSSI
{
    NSArray *systemArray = @[system,RSSI];
    
    if (self.systems.count == 0) {
        [self.systems addObject:systemArray];
        [self.tableView reloadData];
    }else{
        [self.systems enumerateObjectsUsingBlock:^(NSArray *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral* discoveredSystem = [system instance];
            CBPeripheral* targetSystem = [[obj firstObject] instance];
            if ([discoveredSystem.identifier.UUIDString isEqualToString:targetSystem.identifier.UUIDString]) {
                [self.systems replaceObjectAtIndex:idx withObject:systemArray];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                *stop = YES;
            }else if (idx == self.systems.count - 1){
                [self.systems addObject:systemArray];
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)didConnectToSystem:(id)system success:(BOOL)success error:(NSError*)error
{    
    if(success)
    {
        //going to the feature view and need to pass on the connected system
        self.connectedSystem = system;
        [self performSegueWithIdentifier:@"DiscoveryToFeature" sender:self];

    }
}

- (void)didDisconnectToSystem:(id)system error:(NSError *)error
{
    [self.navigationController popToViewController:self animated:YES];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"DiscoveryToFeature"])
    {
        //pass on the connected system and also the systemService. you might want to have a singleton classes to store the service objects and else as an alternatives.
        FeatureTableViewController* featureTableViewController = [segue destinationViewController];
        featureTableViewController.systemService = self.systemService;
        featureTableViewController.system = self.connectedSystem;
        featureTableViewController.model = self.model;
        featureTableViewController.type = self.type;
        
    }
}

@end

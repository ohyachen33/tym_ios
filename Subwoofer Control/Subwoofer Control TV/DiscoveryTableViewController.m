//
//  DiscoveryTableViewController.m
//  Subwoofer Control
//
//  Created by Lam Yick Hong on 5/1/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "DiscoveryTableViewController.h"
#import "SystemManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DiscoverTableViewCell.h"

@interface DiscoveryTableViewController (){
    NSMutableDictionary *dataDictionary;
}
@property (nonatomic, strong)id deviceObserver;
@property (nonatomic, strong)id connectionObserver;
@end

@implementation DiscoveryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataDictionary = [NSMutableDictionary new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.deviceObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SystemDiscoveredNewSystem object:nil queue:nil usingBlock:^(NSNotification* note){
        
        [self updateItems];

    }];
    
    self.connectionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SystemStateDidUpdate object:nil queue:nil usingBlock:^(NSNotification* note){
        
        [self updateItems];
        
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoverTableViewCell" bundle:nil] forCellReuseIdentifier:@"DiscoverTableViewCell"];
}

-(void)updateItems
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray* devices = [SystemManager sharedManager].discoveredSystems;
    
    return [devices count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiscoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoverTableViewCell" forIndexPath:indexPath];
    
    NSArray* devices = [SystemManager sharedManager].discoveredSystems;
    TAPSystem *system = devices[indexPath.row];
    NSString *name = ((CBPeripheral*)[system instance]).name;
    
    TAPSystem *currentSystem = [SystemManager sharedManager].connectedSystem;
    NSString *connectedName = ((CBPeripheral*)[currentSystem instance]).name;
    
    if ([name isEqualToString:connectedName]) {
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ - connected",name];
        cell.nameLabel.textColor = [UIColor greenColor];
    }else{
        cell.nameLabel.text = name;
        cell.nameLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* devices = [SystemManager sharedManager].discoveredSystems;
    TAPSystem *system = devices[indexPath.row];
    NSString *name = ((CBPeripheral*)[system instance]).name;
    
    TAPSystem *currentSystem = [SystemManager sharedManager].connectedSystem;
    NSString *connectedName = ((CBPeripheral*)[currentSystem instance]).name;
    
    if (connectedName.length > 0) {
        if ([name isEqualToString:connectedName]) {
            [[SystemManager sharedManager].systemService disconnectSystem:system];
        }else{
            [[SystemManager sharedManager].systemService disconnectSystem:currentSystem];
            [[SystemManager sharedManager].systemService connectSystem:system];
        }
    }else{
        [[SystemManager sharedManager].systemService connectSystem:system];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  MasterViewController.m
//  Bluetooth Tool
//
//  Created by Lam Yick Hong on 1/7/2016.
//  Copyright © 2016 Tymphany. All rights reserved.
//

#import "MasterViewController.h"
#import "DataDumpViewController.h"

#import "DocumentUtils.h"

@interface MasterViewController ()

@property NSMutableArray *features;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary* featuresDict = [DocumentUtils dictionaryFromResources:@"features"];
    self.features = [featuresDict objectForKey:@"features"];
    self.title = @"Features";

    self.detailViewController = (DataDumpViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDataDump"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary* feature = self.features[indexPath.row];
        DataDumpViewController *controller = (DataDumpViewController *)[[segue destinationViewController] topViewController];
        //[controller setDetailItem:feature];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.features.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary* feature = self.features[indexPath.row];
    cell.textLabel.text = [feature objectForKey:@"title"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

@end

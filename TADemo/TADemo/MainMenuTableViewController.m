//
//  MainMenuTableViewController.m
//  TADemo
//
//  Created by Lam Yick Hong on 11/6/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "MainMenuTableViewController.h"
#import "DiscoveryTableViewController.h"
#import "constant.h"

@interface MainMenuTableViewController()

@property (nonatomic, strong)NSArray* samples;

@end

@implementation MainMenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.samples = @[
                     @{@"title" : kTitleCSR8670, @"filename" : kFilenameCSR8670},
                     @{@"title" : kTitleCSR1010, @"filename" : kFilenameCSR1010}
                     ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainMenuTableCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [[self.samples objectAtIndex:[indexPath row]] objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 0 || [indexPath row] == 1)
    {
        [self performSegueWithIdentifier:@"MainMenuToDiscovery" sender:self];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"MainMenuToDiscovery"])
    {
        //pass on the connected system and also the systemService. you might want to have a singleton classes to store the service objects and else as an alternatives.
        DiscoveryTableViewController* discoveryTableViewController = [segue destinationViewController];
        
        discoveryTableViewController.model = [self.samples objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        
        
    }
}

@end

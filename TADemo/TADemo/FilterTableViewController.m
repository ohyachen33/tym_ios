//
//  FilterTableViewController.m
//  TADemo
//
//  Created by Alain Hsu on 2018/11/13.
//  Copyright © 2018 Tymphany. All rights reserved.
//

#import "FilterTableViewController.h"
#import "SwitchTableViewCell.h"
#import "RangeSliderTableViewCell.h"

@interface FilterTableViewController ()<SwitchTableViewCellDelegate,RangeSliderTableViewCellDelegate,UINavigationControllerDelegate>

@end

@implementation FilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filterIsOn) {
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 40;
    }else{
        return 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"FeatureSwitchTableCell" forIndexPath:indexPath];
        
        SwitchTableViewCell* switchCell = (SwitchTableViewCell*)cell;
        switchCell.delegate = self;
        switchCell.lblTitle.text = @"Filter by RSSI";
        
        switchCell.switchButton.on = self.filterIsOn;
    }else if (indexPath.row == 1){
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"RangeSliderTableViewCell" forIndexPath:indexPath];

        RangeSliderTableViewCell* rangeCell = (RangeSliderTableViewCell*)cell;
        rangeCell.delegate = self;
        rangeCell.title.text = [NSString stringWithFormat:@"RSSI range(dB): %.0f to %.0f", self.left,self.right];        
        rangeCell.slider.minimumSize = 1.0;
        rangeCell.slider.minValue = -100;
        rangeCell.slider.maxValue = -30;
        rangeCell.slider.leftValue = self.left;
        rangeCell.slider.rightValue = self.right;
        [rangeCell.slider usingValueUnequal];
    }
    // Configure the cell...
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)cell:(SwitchTableViewCell *)cell onSwitchChanged:(id)sender {
    self.filterIsOn = ((UISwitch*)sender).isOn;
    if (self.filterIsOn) {
        self.left = -53;
        self.right = -37;
    }
    [self.tableView reloadData];
}

- (void)cell:(RangeSliderTableViewCell *)cell onValueChangedFromLeft:(double)leftValue toRight:(double)rightValue
{
    self.left = leftValue;
    self.right = rightValue;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UINavigationBarDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[self class]]) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSetFilter:from:to:)]) {
        [self.delegate didSetFilter:self.filterIsOn from:self.left to:self.right];
    }
}

@end

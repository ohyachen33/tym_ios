//
//  PopTableViewController.m
//  SVS16UltraApp
//
//  Created by Zhikuan.Yan on 7/29/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import "PopTableViewController.h"
#import "PopTableViewCell.h"
#import "ThemeUtils.h"

@interface PopTableViewController () {
    UIControl *_overlayView;
    NSString * mTitle;
    NSArray * itemArray;
    
    void (^completionExitBlcok)(NSInteger selectedItemIndex);
}

- (void)fadeIn;
- (void)fadeOut;

@end

@implementation PopTableViewController


-(id)initWithTitle: (NSString*)title  items: (NSArray*)items {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    int tableViewHeight = MAX (44 * (int)[items count], 44 * 5); // as least 5 item height
    tableViewHeight = MIN(352, tableViewHeight); // but won't be too much
    
    CGRect centerRect = CGRectMake(25, (screenRect.size.height-tableViewHeight-30)/2,
                                    screenRect.size.width-50, tableViewHeight+72);
    self = [self initWithFrame:centerRect];
    if(self) {
        
        mTitle = title;
        itemArray = [NSArray  arrayWithArray:items];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, self.bounds.size.width-50, 21)];
        self.titleLabel.text = mTitle;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:18];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(25, 52, self.bounds.size.width-50, tableViewHeight)];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 15)];
        view.backgroundColor = [UIColor clearColor];
        
        self.tableView.tableHeaderView = view;
        
        [self addSubview:self.tableView];
        
        
        _overlayView = [[UIControl alloc] initWithFrame:screenRect];
        _overlayView.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
        [_overlayView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [ThemeUtils roundCorner:self];
        
        return self;
    }
    
    return nil;
}


#pragma mark - animations
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [_overlayView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}


-(void)show:(void (^)(NSInteger selectedItemIndex))complete {
    
    completionExitBlcok =  complete;
    
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:_overlayView];
    [keywindow addSubview:self];
    
    [self fadeIn];
}

-(void)updateItems:(NSArray*)items
{
    itemArray = items;
    [self.tableView reloadData];
}


- (void)dismiss
{
    [self fadeOut];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [itemArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil) {
        cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    if(cell) {
        [cell.textLabel setText:[itemArray objectAtIndex:indexPath.row]];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Th" size:14];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismiss];
    
    if(completionExitBlcok!=nil)
      completionExitBlcok(indexPath.row);
    
    // Navigation logic may go here, for example:
    // Create the next view controller.
    // *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
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

//
//  PopTableViewController.h
//  SVS16UltraApp
//
//  Created by Zhikuan.Yan on 7/29/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopTableViewDelegate <NSObject>
@optional
- (void)PopTableViewCancel;
@end

@interface PopTableViewController : UIView<UITableViewDataSource, UITableViewDelegate>{
    void (^completionExitBlcok)(NSInteger selectedItemIndex);
}

@property (atomic) IBOutlet UILabel * titleLabel;
@property (atomic) IBOutlet UIImageView * lineImageView;
@property (atomic) IBOutlet UITableView * tableView;
@property (nonatomic, assign) id<PopTableViewDelegate> delegate;

-(id)initWithTitle:(NSString*)title items: (NSArray*)items;
-(void)show:(void (^)(NSInteger selectedItemIndex))complete;
-(void)fadeOut;
-(void)updateItems:(NSArray*)items;

@end

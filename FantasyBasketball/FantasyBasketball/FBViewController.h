//
//  FBViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBPickerView.h"
#import "FBSession.h"
#import "FBPlayer.h"
#import "TFHpple.h"
#import "RESideMenu.h"
#import "PlayerCell.h"
#import "ZFModalTransitionAnimator.h"
#import "PlayerViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"

@interface FBViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FBPickerViewDelegate, PlayerCellDelegate>

@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

@property (strong, nonatomic) FBSession *session;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)fadeOutWithPickerView: (FBPickerView *) pickerView;

@end

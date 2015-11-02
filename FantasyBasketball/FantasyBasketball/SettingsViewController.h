//
//  SettingsViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSession.h"
#import "RESideMenu.h"
#import "AppDelegate.h"
#import "SessionViewController.h"
#import "ZFModalTransitionAnimator.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SessionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

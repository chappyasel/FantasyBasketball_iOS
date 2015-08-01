//
//  MyTeamViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerCell.h"
#import "RESideMenu.h"
#import "FBPickerView.h"

@interface MyTeamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FBPickerViewDelegate, PlayerCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

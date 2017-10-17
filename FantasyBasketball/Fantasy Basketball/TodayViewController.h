//
//  TodayViewController.h
//  Fantasy Basketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *team1Display1;
@property (weak, nonatomic) IBOutlet UILabel *team1Display2;
@property (weak, nonatomic) IBOutlet UILabel *team2Display1;
@property (weak, nonatomic) IBOutlet UILabel *team2Display2;

@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedDisplay;
@end


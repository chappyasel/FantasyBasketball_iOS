//
//  MatchupViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "FBViewController.h"
#import "MatchupPlayerCell.h"
#import "JBChartView.h"
#import "JBBarChartView.h"
#import "MatchupHeaderView.h"

@interface MatchupViewController : FBViewController <UIScrollViewDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate>

@property (nonatomic) MatchupHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UILabel *team1Display1;
@property (weak, nonatomic) IBOutlet UILabel *team1Display2;
@property (weak, nonatomic) IBOutlet UILabel *team1Display3;
@property (weak, nonatomic) IBOutlet UILabel *team2Display1;
@property (weak, nonatomic) IBOutlet UILabel *team2Display2;
@property (weak, nonatomic) IBOutlet UILabel *team2Display3;
@property (weak, nonatomic) IBOutlet UILabel *centerDisplay;

- (void)initWithMatchupLink: (NSString *) link;

@end

//
//  MatchupViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "FBViewController.h"
#import "MatchupPlayerCell.h"

@interface MatchupViewController : FBViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (strong, nonatomic) IBOutlet UISwitch *autorefreshSwitch;
@property (weak, nonatomic) IBOutlet UILabel *team1Display1;
@property (weak, nonatomic) IBOutlet UILabel *team1Display2;
@property (weak, nonatomic) IBOutlet UILabel *team2Display1;
@property (weak, nonatomic) IBOutlet UILabel *team2Display2;

@end

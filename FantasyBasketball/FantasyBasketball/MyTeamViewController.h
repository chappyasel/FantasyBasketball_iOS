//
//  MyTeamViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "FBViewController.h"
#import "PlayerCell.h"
#import "FBPickerView.h"

@interface MyTeamViewController : FBViewController <UIScrollViewDelegate, FBPickerViewDelegate>

@property NSString *scoringPeriod; //span of stats

- (void)initWithTeamLink: (NSString *) link;

@end

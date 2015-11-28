//
//  ScoreboardViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBViewController.h"
#import "ScoreboardCell.h"

@interface ScoreboardViewController : FBViewController <ScoreboardCellDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet UISwitch *autorefreshSwitch;

@end

//
//  MatchupPlayerCell.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/28/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBPlayer.h"
#import <WebKit/WebKit.h>
#import "PlayerCell.h"

@interface MatchupPlayerCell : UITableViewCell

@property (nonatomic, weak) id <PlayerCellDelegate> delegate;
@property (nonatomic) int index;
@property (nonatomic) FBPlayer *rightPlayer;
@property (nonatomic) FBPlayer *leftPlayer;

- (instancetype) initWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP view:(UIViewController *)superview expanded:(bool)expanded size: (CGSize) size;

- (void)updateWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP;

@end

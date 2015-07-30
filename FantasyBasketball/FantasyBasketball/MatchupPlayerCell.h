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

@protocol MatchupPlayerCellDelegate <NSObject>

- (void)linkWithPlayer:(FBPlayer *)player;
- (void)linkWithGameLink:(FBPlayer *)player;

@end

@interface MatchupPlayerCell : UITableViewCell

@property (nonatomic, weak) id <MatchupPlayerCellDelegate> delegate;
@property (nonatomic) int index;
@property (nonatomic) FBPlayer *rightPlayer;
@property (nonatomic) FBPlayer *leftPlayer;

- (instancetype) initWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP view:(UIViewController *)superview expanded:(bool)expanded;

- (void)updateWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP;

@end

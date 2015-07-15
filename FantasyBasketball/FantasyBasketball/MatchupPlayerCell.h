//
//  MatchupPlayerCell.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/28/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"
#import <WebKit/WebKit.h>

@protocol MatchupPlayerCellDelegate <NSObject>

- (void)linkWithPlayer:(Player *)player;
- (void)linkWithGameLink:(Player *)player;

@end

@interface MatchupPlayerCell : UITableViewCell

@property (nonatomic, weak) id <MatchupPlayerCellDelegate> delegate;
@property (nonatomic) int index;
@property (nonatomic) Player *rightPlayer;
@property (nonatomic) Player *leftPlayer;

- (instancetype) initWithRightPlayer:(Player *)rP leftPlayer:(Player *)lP view:(UIViewController *)superview expanded:(bool)expanded;

- (void)updateWithRightPlayer:(Player *)rP leftPlayer:(Player *)lP;

@end

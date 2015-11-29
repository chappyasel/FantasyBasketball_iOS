//
//  PlayerCellPL.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/26/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBPlayer.h"

@protocol PlayerCellDelegate <NSObject>

- (void)linkWithPlayer:(FBPlayer *)player;
- (void)linkWithGameLink:(FBPlayer *)player;
- (void)togglePlayer: (FBPlayer *)player WLStatusToState: (BOOL) isOnWL;

@end

@interface PlayerCell : UITableViewCell

@property (nonatomic, weak) id <PlayerCellDelegate> delegate;
@property (nonatomic) FBPlayer *player;
@property BOOL isOnWL;

- (instancetype) initWithPlayer:(FBPlayer *)pl
                           view:(UIViewController<UIScrollViewDelegate> *)superview
                         isOnWL:(BOOL) isOnWL
                           size:(CGSize) size;

- (void)setScrollDistance:(float)dist;

@end

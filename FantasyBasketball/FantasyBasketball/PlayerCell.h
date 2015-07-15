//
//  PlayerCellPL.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/26/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@protocol PlayerCellDelegate <NSObject>

- (void)linkWithPlayer:(Player *)player;
- (void)linkWithGameLink:(Player *)player;

@end

@interface PlayerCell : UITableViewCell

@property (nonatomic, weak) id <PlayerCellDelegate> delegate;
@property (nonatomic) Player *player;

- (instancetype) initWithPlayer:(Player *)pl view:(UIViewController<UIScrollViewDelegate> *)superview scrollDistance:(float)dist;

- (void)setScrollDistance:(float)dist;

@end

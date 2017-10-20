//
//  MatchupPlayerCell.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/28/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBPlayer.h"
#import "PlayerCell.h"
#import "FBWinProbablityPlayer.h"

@interface MatchupPlayerCell : UITableViewCell

@property (nonatomic, weak) id <PlayerCellDelegate> delegate;
@property (nonatomic) int index;
@property (nonatomic) FBPlayer *rightPlayer;
@property (nonatomic) FBPlayer *leftPlayer;

- (void)loadWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP expanded:(bool)expanded;

- (void)updateWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP;

- (void)loadWinProbabilityRightPlayer: (FBWinProbablityPlayer *)wpRightPlayer leftPlayer: (FBWinProbablityPlayer *) wpLeftPlayer;

@end

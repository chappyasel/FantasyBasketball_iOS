//
//  FBWinProbablity.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBWinProbablityPlayer.h"

@interface FBWinProbablity : NSObject

@property float team1WinPct;
@property int team1ProjScore;
@property int team2ProjScore;

@property NSMutableDictionary<NSString *, FBWinProbablityPlayer *> *team1Players;
@property NSMutableDictionary<NSString *, FBWinProbablityPlayer *> *team2Players;

@property NSString *matchupLink;

- (void)loadComparisonWithUpdateBlock: (void (^)(int num, int total))update;

- (void)updateComparisonWithCompletionBlock: (void (^)(void))completion;

@end

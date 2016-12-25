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
@property float team1ProjScore;
@property float team2ProjScore;

@property float team1ProjScoreToday;
@property float team2ProjScoreToday;

@property NSMutableDictionary<NSString *, FBWinProbablityPlayer *> *team1Players;
@property NSMutableDictionary<NSString *, FBWinProbablityPlayer *> *team2Players;

@property NSString *matchupLink;

- (void)loadProjectionsWithUpdateBlock: (void (^)(int num, int total))update;

- (void)updateProjectionsWithCompletionBlock: (void (^)(void))completion;

- (void)setTodayProjectionsToDayWithLink: (NSString *)link;

@end

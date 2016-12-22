//
//  FBTeamComparison.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBTeamComparisonPlayer.h"

@interface FBTeamComparison : NSObject

@property float team1WinPct;
@property int team1ProjScore;
@property int team2ProjScore;

@property NSMutableDictionary<NSString *, FBTeamComparisonPlayer *> *team1Players;
@property NSMutableDictionary<NSString *, FBTeamComparisonPlayer *> *team2Players;

- (void)loadComparisonWithMatchupLink: (NSString *)link updateBlock: (void (^)(int num, int total))update;

@end

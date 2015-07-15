//
//  Session.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface Session : NSObject

@property int leagueID;
@property int teamID;
@property int seasonID;
@property int scoringPeriodID;

@property Player *player;
@property NSString *link;

+ (Session *)sharedInstance;

@end

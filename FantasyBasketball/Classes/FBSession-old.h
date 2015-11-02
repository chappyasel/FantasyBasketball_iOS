//
//  Session.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBPlayer.h"

@interface FBSession : NSObject //default session set in appdelegate.m

@property int leagueID;
@property int teamID;
@property int seasonID;
@property int scoringPeriodID; //all session variables set in AppDelegate.m

@property FBPlayer *player;
@property NSString *link;

+ (FBSession *)sharedInstance;

@end

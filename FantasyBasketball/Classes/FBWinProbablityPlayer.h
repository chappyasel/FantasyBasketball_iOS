//
//  FBWinProbablityPlayer.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBWinProbablityPlayer : NSObject

@property NSString *firstName;
@property NSString *lastName;

@property float average;
@property float variance;

@property int injuryStatus; // 0 = Healthy, 1 = DTD, 2 = Out

@property BOOL gameToday;
@property int gameTodayScore;
@property float gameTodayProgress; // 0 - 1 (0 = game not started, 1 = game over)

@property NSMutableArray<NSNumber *> *scores;

- (void)loadPlayerWithName: (NSString *)name;

- (void)addScore: (id)score;

@end

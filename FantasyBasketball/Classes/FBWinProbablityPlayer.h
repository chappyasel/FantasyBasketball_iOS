//
//  FBWinProbablityPlayer.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBWinProbabilityGame.h"

@interface FBWinProbablityPlayer : NSObject

@property NSString *firstName;
@property NSString *lastName;
@property int teamNum;

@property float average;
@property float variance;
@property float standardDeviation;

@property int injuryStatus; // 0 = Healthy, 1 = DTD, 2 = Out

@property NSMutableArray *games;

- (void)loadPlayerWithName: (NSString *)name;

- (void)addGame: (FBWinProbabilityGame *)game atIndex: (int)index;

@end

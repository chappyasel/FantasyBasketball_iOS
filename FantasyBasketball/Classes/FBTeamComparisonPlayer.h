//
//  FBTeamComparisonPlayer.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBTeamComparisonPlayer : NSObject

@property NSString *firstName;
@property NSString *lastName;

@property float average;
@property float variance;

@property NSMutableArray<NSNumber *> *scores;

- (void)loadPlayerWithName: (NSString *)name;

- (void)addScore: (id)score;

@end

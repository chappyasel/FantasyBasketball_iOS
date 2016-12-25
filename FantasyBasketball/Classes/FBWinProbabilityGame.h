//
//  FBWinProbabilityGame.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/24/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBWinProbabilityGame : NSObject

@property int score;
@property float progress;  // 0 - 1 (0 = game not started, 1 = game over)

+(FBWinProbabilityGame *)gameWithScore: (int)score gameStatus: (NSString *)gameStatus;

- (void)updateWithGameStatus: (NSString *)gameStatus;

+ (float)progressForGameStatus: (NSString *)status;

@end

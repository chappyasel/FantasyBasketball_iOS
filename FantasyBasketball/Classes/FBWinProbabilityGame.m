//
//  FBWinProbabilityGame.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/24/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import "FBWinProbabilityGame.h"

@implementation FBWinProbabilityGame

+(FBWinProbabilityGame *)gameWithScore: (int)score gameStatus: (NSString *)gameStatus {
    FBWinProbabilityGame *game = [[FBWinProbabilityGame alloc] init];
    game.score = score;
    game.progress = [FBWinProbabilityGame progressForGameStatus:gameStatus];
    return game;
}

- (void)updateWithScore:(int)score gameStatus:(NSString *)gameStatus {
    self.score = score;
    self.progress = [FBWinProbabilityGame progressForGameStatus:gameStatus];
}

+ (float)progressForGameStatus: (NSString *)status {
    if      ([status containsString:@"L"] || [status containsString:@"W"]) return 1;
    if      ([status containsString:@"AM"] || [status containsString:@"PM"]) return 0;
    if      ([status containsString:@"Half"]) return .5;
    float progress = 0;
    if      ([status containsString:@"1st"]) progress += .0;
    else if ([status containsString:@"2nd"]) progress += .25;
    else if ([status containsString:@"3rd"]) progress += .50;
    else                                     progress += .75; //OT handled appropriately due to 5:00 length
    if ([status containsString:@"End"]) progress += .25;
    else {
        int loc = (int)[status rangeOfString:@":"].location;
        float timeMinute = [[status substringWithRange:NSMakeRange(loc-2, 2)] intValue];
        float timeSecond = [[status substringWithRange:NSMakeRange(loc+1, 2)] intValue];
        progress += (1-timeMinute/12)/4;
        progress += -timeSecond/60/12/4;
    }
    return MIN(1, progress);
}

@end

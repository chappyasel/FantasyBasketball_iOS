//
//  FBWinProbablity.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import "FBWinProbablity.h"
#import "TFHpple.h"

@interface FBWinProbablity()

@property BOOL isUpdating;

@end

@implementation FBWinProbablity

- (void)loadComparisonWithUpdateBlock: (void (^)(int num, int total))update {
    self.isUpdating = NO;
    int __block numPlayersFinished = 0;
    int numPlayersAnticipated = 24; //12 players * 2
    int numStepsFinished = 0;
    int numStepsAnticipated = 9; //1 linkBar, 7 days, 1 data
    update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
    
    self.team1Players = [[NSMutableDictionary alloc] init];
    self.team2Players = [[NSMutableDictionary alloc] init];
    
    NSURL *url = [NSURL URLWithString:self.matchupLink];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Comparison error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//div[@class='games-fullcol games-fullcol-extramargin']/div[@class='bodyCopy']"];
    NSArray *linkBar = [nodes[1] children];
    NSMutableArray *links = [[NSMutableArray alloc] init];
    int todayInsertion = 0, x = 0;
    for (int i = 4; i < linkBar.count; i++) {
        TFHppleElement *element = linkBar[i];
        if (![element.content containsString:@"|"]) {
            if ([element.content containsString:@"Today"]) todayInsertion = x;
            else [links addObject:[element objectForKey:@"href"]];
            x++;
        }
    }
    [links insertObject:self.matchupLink atIndex:todayInsertion];
    numStepsFinished ++;
    update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
    
    for (NSString *l in links) {
        [self loadMatchupLink:l withPlayerLoadUpdateBlock:^{
            numPlayersFinished = MIN(24, numPlayersFinished + 1);
            update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
        }];
        numStepsFinished ++;
        update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
    }
    
    [self calculateWinProbablity];
    numStepsFinished ++;
    update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
}

- (void)updateComparisonWithCompletionBlock: (void (^)(void))completion { //assumes injuries, player means and variances are constant
    self.isUpdating = YES;
    [self loadMatchupLink:self.matchupLink withPlayerLoadUpdateBlock:^{}];
    [self calculateWinProbablity];
    completion();
}

- (void)loadMatchupLink: (NSString *)link withPlayerLoadUpdateBlock: (void (^)(void))playerLoad {
    NSURL *url = [NSURL URLWithString:link];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Comparison error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//table[@class='playerTableTable tableBody']/tr"];
    if (nodes.count == 0) {
        NSLog(@"Comparison error: 0 Nodes");
        return;
    }
    int switchPoint = 0;
    bool switchValid = YES;
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSArray <TFHppleElement *> *children = element.children;
            BOOL isStarting = (!([children[0].content isEqual:@"Bench"] || [children[0].content isEqual:@"IR"]));
            BOOL isPlaying = ![children[3].content isEqualToString:@""];
            BOOL gameOver = [children[3].content containsString:@"L"] || [children[3].content containsString:@"W"];
            NSString *gameStatus = children[3].content;
            NSString *name = [children[1].children[0] content];
            int injuryStatus = 0;
            if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"]) {
                if ([[children[1].children[2] content] containsString:@"O"]) injuryStatus = 2;
                else injuryStatus = 1;
            }
            NSNumber *fpts = [NSNumber numberWithInt:[children[18].content intValue]];
            if (switchValid) switchPoint ++;
            if (isPlaying && isStarting) {
                FBWinProbablityPlayer *player;
                if (!self.team1Players[name] && !self.team2Players[name]) {
                    player = [[FBWinProbablityPlayer alloc] init];
                    [player loadPlayerWithName:name];
                    player.injuryStatus = injuryStatus;
                    if (switchValid) [self.team1Players setObject:player forKey:name];
                    else [self.team2Players setObject:player forKey:name];
                    playerLoad();
                }
                player = (switchValid) ? self.team1Players[name] : self.team2Players[name];
                if (isPlaying && [link isEqualToString:self.matchupLink]) { //playing in a game today
                    player.gameToday = YES;
                    player.gameTodayScore = fpts.intValue;
                    if (gameOver) player.gameTodayProgress = 1;
                    else player.gameTodayProgress = [self progressForGameStatus:gameStatus];
                }
                if(!self.isUpdating) {
                    if (gameOver) [player addScore:fpts];
                    else [player addScore:[NSNull null]];
                }
            }
        }
        else if (switchPoint != 0) switchValid = NO;
    }
}

- (float)progressForGameStatus: (NSString *)status {
    float progress = 0;
    if      ([status containsString:@"Half"]) return .5;
    if      ([status containsString:@"AM"] || [status containsString:@"PM"]) return 0;
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
    return MIN(1.0, progress);
}

- (void)calculateWinProbablity {
    NSMutableDictionary <NSString *, NSNumber *> *team1 = [self statsForPlayerArray:[self.team1Players allValues]];
    NSMutableDictionary <NSString *, NSNumber *> *team2 = [self statsForPlayerArray:[self.team2Players allValues]];
    float sumMean = team1[@"total"].floatValue - team2[@"total"].floatValue;
    float sumSTD = sqrt(team1[@"variance"].floatValue + team2[@"variance"].floatValue);
    float chance = 0.5 * erfcf((sumMean/sumSTD) * M_SQRT1_2);
    self.team1ProjScore = team1[@"total"].floatValue;
    self.team2ProjScore = team2[@"total"].floatValue;
    self.team1WinPct = 100-chance*100;
    //NSLog(@"\nteam 1: %f \nteam 2: %f \nchance: %f",self.team1ProjScore,self.team2ProjScore,self.team1WinPct);
}

- (NSMutableDictionary *)statsForPlayerArray: (NSArray *)arr {
    //NSLog(@"%@",arr);
    float projTotal = 0; //if the whole week went as simulated
    float total = 0; //results of this week combined with simulation of remaining scores
    float variance = 0;
    for(FBWinProbablityPlayer *player in arr) {
        BOOL DTDValid = YES;
        BOOL gameTodayValid = YES;
        for (NSNumber *score in player.scores) {
            projTotal += player.average;
            if (score.class == [NSNull class]) {
                if (player.injuryStatus == 0) {
                    if (player.gameToday && gameTodayValid) {
                        total += player.gameTodayScore + player.average * (1-player.gameTodayProgress);
                        variance += player.variance * (1-player.gameTodayProgress);
                    }
                    else {
                        total += player.average;
                        variance += player.variance;
                    }
                }
                else if (player.injuryStatus == 1 && !DTDValid) {
                    total += player.average;
                    variance += player.variance;
                }
                DTDValid = NO;
                gameTodayValid = NO;
            }
            else total += score.intValue;
        }
    }
    return [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithFloat:projTotal],
                                                          [NSNumber numberWithFloat:total],
                                                          [NSNumber numberWithFloat:variance]]
                                                forKeys:@[@"projTotal", @"total", @"variance"]];
}

@end

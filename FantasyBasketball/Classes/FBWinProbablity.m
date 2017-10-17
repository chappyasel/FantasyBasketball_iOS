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
@property BOOL calcInProcess;

@property int todayIndex;

@property NSMutableArray<NSString *> *playersLoading;

@property NSMutableArray<NSString *> *dayLinks;
@property NSMutableArray<NSNumber *> *dayProjectionsTeam1;
@property NSMutableArray<NSNumber *> *dayProjectionsTeam2;
@property NSMutableArray<NSNumber *> *dayVariancesTeam1;
@property NSMutableArray<NSNumber *> *dayVariancesTeam2;

@end

@implementation FBWinProbablity

- (void)loadProjectionsWithUpdateBlock:(void (^)(int num, int total))update {
    if (self.calcInProcess) return;
    self.calcInProcess = YES;
    self.isUpdating = NO;
    int __block numPlayersFinished = 0;
    int numPlayersAnticipated = 26; //13 players * 2
    int __block numStepsFinished = 0;
    int numStepsAnticipated = 9; //1 linkBar, 7 days, 1 data
    update(0, numPlayersAnticipated + numStepsAnticipated);
    
    self.team1Players = [[NSMutableDictionary alloc] init];
    self.team2Players = [[NSMutableDictionary alloc] init];
    self.dayLinks = [[NSMutableArray alloc] init];
    
    //DAY LINKS
    NSURL *url = [NSURL URLWithString:self.matchupLink];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Comparison error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//div[@class='games-fullcol games-fullcol-extramargin']/div[@class='bodyCopy']"];
    NSArray *linkBar = [nodes[1] children];
    int x = 0;
    for (int i = 4; i < linkBar.count; i++) {
        TFHppleElement *element = linkBar[i];
        if (![element.content containsString:@"|"]) {
            if ([element.content containsString:@"Today"]) self.todayIndex = x;
            else [self.dayLinks addObject:[element objectForKey:@"href"]];
            x++;
        }
    }
    [self.dayLinks insertObject:self.matchupLink atIndex:self.todayIndex];
    numStepsFinished ++;
    update(0 + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
    
    int __block numDays = 0;
    self.playersLoading = @[].mutableCopy;
    for (NSString *l in self.dayLinks) {
        dispatch_queue_t myQueue = dispatch_queue_create("Queue",NULL);
        dispatch_async(myQueue, ^{
            [self loadMatchupLink:l withPlayerLoadBlock:^{
                numPlayersFinished = MIN(26, (int)self.team1Players.count + (int)self.team2Players.count);
                update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
            } completionBlock:^{
                numStepsFinished ++;
                update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
                numDays ++;
                if (numDays == self.dayLinks.count) {
                    [self calculateWinProbablity];
                    numStepsFinished ++;
                    update(numPlayersAnticipated + numStepsAnticipated, numPlayersAnticipated + numStepsAnticipated);
                    self.calcInProcess = NO;
                }
            }];
        });
    }
}

- (void)updateProjectionsWithCompletionBlock:(void (^)(void))completion { //assumes injuries, player means and variances are constant
    if (self.calcInProcess) return;
    self.calcInProcess = YES;
    self.isUpdating = YES;
    [self loadMatchupLink:self.matchupLink withPlayerLoadBlock:nil completionBlock:nil];
    [self calculateWinProbablity];
    completion();
    self.calcInProcess = NO;
}

- (void)setTodayProjectionsToDayWithLink:(NSString *)link {
    int index = (int)[self.dayLinks indexOfObject:link];
    self.team1ProjScoreToday = (index == -1)? 0 : self.dayProjectionsTeam1[index].floatValue;
    self.team2ProjScoreToday = (index == -1)? 0 : self.dayProjectionsTeam2[index].floatValue;
}

- (void)loadMatchupLink:(NSString *)link withPlayerLoadBlock:(void (^)(void))playerLoad completionBlock:(void (^)(void))completed {
    int index = (int)[self.dayLinks indexOfObject:link];
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
            NSString *gameStatus = children[3].content;
            NSString *name = [children[1].children[0] content];
            int injuryStatus = 0;
            if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"]) {
                if ([[children[1].children[2] content] containsString:@"O"]) injuryStatus = 2;
                else injuryStatus = 1;
            }
            int fpts = [children[18].content intValue];
            if (switchValid) switchPoint ++;
            if (isPlaying && isStarting) {
                FBWinProbablityPlayer *player;
                if (!self.team1Players[name] && !self.team2Players[name]) {
                    player = [[FBWinProbablityPlayer alloc] init];
                    if (![self.playersLoading containsObject:name]) {
                        NSMutableArray *temp = self.playersLoading.mutableCopy;
                        [temp addObject:name];
                        self.playersLoading = temp;
                        [player loadPlayerWithName:name completionBlock:^{
                            player.injuryStatus = injuryStatus;
                            player.teamNum = (switchValid)? 1 : 2;
                            if (switchValid) [self.team1Players setObject:player forKey:name];
                            else [self.team2Players setObject:player forKey:name];
                            NSMutableArray *temp = self.playersLoading.mutableCopy;
                            [temp removeObject:name];
                            self.playersLoading = temp;
                            playerLoad();
                        }];
                    }
                    else
                        while (true)
                            if (![self.playersLoading containsObject:name])
                                break;
                }
                player = (switchValid) ? self.team1Players[name] : self.team2Players[name];
                if (self.isUpdating) [player.games[index] updateWithScore:fpts gameStatus:gameStatus];
                else                 [player addGame:[FBWinProbabilityGame gameWithScore:fpts gameStatus:gameStatus] atIndex:index];
            }
        }
        else if (switchPoint != 0) switchValid = NO;
    }
    completed();
}

- (void)calculateWinProbablity {
    if (self.isUpdating) //recalculate 1 day
        [self calculateStatsForDayIndex:self.todayIndex];
    else { //calculate all days
        self.dayProjectionsTeam1 = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, @0, @0, @0, @0, nil];
        self.dayProjectionsTeam2 = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, @0, @0, @0, @0, nil];
        self.dayVariancesTeam1 = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, @0, @0, @0, @0, nil];
        self.dayVariancesTeam2 = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, @0, @0, @0, @0, nil];
        for (int i = 0; i < 7; i++) [self calculateStatsForDayIndex:i];
    }
    self.team1ProjScore = 0;
    self.team2ProjScore = 0;
    float team1Variance = 0;
    float team2Variance = 0;
    for (int i = 0; i < 7; i++) {
        self.team1ProjScore += self.dayProjectionsTeam1[i].floatValue;
        self.team2ProjScore += self.dayProjectionsTeam2[i].floatValue;
        team1Variance += self.dayVariancesTeam1[i].floatValue;
        team2Variance += self.dayVariancesTeam2[i].floatValue;
    }
    float sumMean = self.team1ProjScore - self.team2ProjScore;
    float sumSTD = sqrt(team1Variance + team2Variance);
    float chance = 0.5 * erfcf((sumMean/sumSTD) * M_SQRT1_2);
    self.team1WinPct = 100-chance*100;
    //NSLog(@"\nteam 1: %f \nteam 2: %f \nchance: %f",self.team1ProjScore,self.team2ProjScore,self.team1WinPct);
}

- (void)calculateStatsForDayIndex:(int)index {
    [self calculateStatsForTeamNumber:1 dayIndex:index];
    [self calculateStatsForTeamNumber:2 dayIndex:index];
}

- (void)calculateStatsForTeamNumber:(int)num dayIndex:(int)index {
    NSArray *arr = (num == 1)? [self.team1Players allValues] : [self.team2Players allValues];
    float total = 0;
    float variance = 0;
    for(FBWinProbablityPlayer *player in arr) {
        if ([player.games[index] class] != [NSNull class]) {
            FBWinProbabilityGame *game = player.games[index];
            if (game.progress == 1) //game over
                total += game.score;
            else { //game not started/in progress
                if (player.injuryStatus == 0) {
                    total += game.score + player.average * (1-game.progress);
                    variance += player.variance * (1-game.progress);
                }
                else if (game.score != 0) {
                    total += game.score + player.average * (1-game.progress);
                    variance += player.variance * (1-game.progress);
                }
                else if (player.injuryStatus == 1 && index != self.todayIndex) {
                    total += game.score + player.average * (1-game.progress);
                    variance += player.variance * (1-game.progress);
                }
            }
        }
    }
    if (num == 1) {
        self.dayProjectionsTeam1[index] = [NSNumber numberWithFloat:total];
        self.dayVariancesTeam1[index] = [NSNumber numberWithFloat:variance];
    }
    else {
        self.dayProjectionsTeam2[index] = [NSNumber numberWithFloat:total];
        self.dayVariancesTeam2[index] = [NSNumber numberWithFloat:variance];
    }
}

@end

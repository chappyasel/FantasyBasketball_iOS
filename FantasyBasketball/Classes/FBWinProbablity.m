//
//  FBWinProbablity.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import "FBWinProbablity.h"
#import "TFHpple.h"

@implementation FBWinProbablity

- (void)loadComparisonWithUpdateBlock: (void (^)(int num, int total))update {
    int numPlayersFinished = 0;
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
        NSURL *url = [NSURL URLWithString:l];
        NSError *error;
        NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
        if (error) NSLog(@"Comparison error: %@",error);
        parser = [TFHpple hppleWithHTMLData:html];
        NSArray *nodes = [parser searchWithXPathQuery:@"//table[@class='playerTableTable tableBody']/tr"];
        if (nodes.count == 0) {
            NSLog(@"Comparison error: 0 Nodes");
            update(0,0);
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
                BOOL gameOccured = [children[3].content containsString:@"L"] || [children[3].content containsString:@"W"];
                NSString *name = [children[1].children[0] content];
                //if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"])
                //    [dict setObject:[children[1].children[2] content] forKey:@"injury"];
                //[dict setObject:children[3].content forKey:@"isPlaying+gameState+score+status"];
                NSNumber *fpts = [NSNumber numberWithInt:[children[18].content intValue]];
                if (switchValid) switchPoint ++;
                if (isPlaying && isStarting) {
                    if (!self.team1Players[name] && !self.team2Players[name]) {
                        FBWinProbablityPlayer *player = [[FBWinProbablityPlayer alloc] init];
                        [player loadPlayerWithName:name];
                        if (switchValid) [self.team1Players setObject:player forKey:name];
                        else [self.team2Players setObject:player forKey:name];
                        numPlayersFinished = MIN(24, numPlayersFinished + 1);
                        update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
                    }
                    if (gameOccured) {
                        if (switchValid) [self.team1Players[name] addScore:fpts];
                        else [self.team2Players[name] addScore:fpts];
                    }
                    else {
                        if (switchValid) [self.team1Players[name] addScore:[NSNull null]];
                        else [self.team2Players[name] addScore:[NSNull null]];
                    }
                }
            }
            else if (switchPoint != 0) switchValid = NO;
        }
        numStepsFinished ++;
        update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
    }
    
    [self calculateWinProbablity];
    numStepsFinished ++;
    update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
}

- (void)updateComparisonWithCompletionBlock: (void (^)(void))completion { //assumes injuries, player means and variances are constant
    
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
    //NSLog(@"\nteam 1: %f %f \nteam 2: %f %f \nchance: %f",team1Total,team1Variance,team2Total,team2Variance,self.team1WinPct);
}

- (NSMutableDictionary *)statsForPlayerArray: (NSArray *)arr {
    float projTotal = 0; //if the whole week went as simulated
    float total = 0; //results of this week combined with simulation of remaining scores
    float variance = 0;
    for(FBWinProbablityPlayer *player in arr) {
        for (NSNumber *score in player.scores) {
            projTotal += player.average;
            if (score.class != [NSNull class]) total += score.intValue;
            else {
                total += player.average;
                variance += player.variance;
            }
        }
    }
    return [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithFloat:projTotal],
                                                          [NSNumber numberWithFloat:total],
                                                          [NSNumber numberWithFloat:variance]]
                                                forKeys:@[@"projTotal", @"total", @"variance"]];
}

@end

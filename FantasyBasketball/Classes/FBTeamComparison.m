//
//  FBTeamComparison.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 12/19/16.
//  Copyright © 2016 CD. All rights reserved.
//

#import "FBTeamComparison.h"
#import "TFHpple.h"

@implementation FBTeamComparison

- (void)loadComparisonWithMatchupLink: (NSString *)link updateBlock: (void (^)(int num, int total))update {
    int numPlayersFinished = 0;
    int numPlayersAnticipated = 24; //12 players * 2
    int numStepsFinished = 0;
    int numStepsAnticipated = 9; //1 linkBar, 7 days, 1 data
    update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
    
    self.team1Players = [[NSMutableDictionary alloc] init];
    self.team2Players = [[NSMutableDictionary alloc] init];
    
    NSURL *url = [NSURL URLWithString:link];
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
    [links insertObject:link atIndex:todayInsertion];
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
                        FBTeamComparisonPlayer *player = [[FBTeamComparisonPlayer alloc] init];
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
    
    float team1ProjTotal = 0; //if the whole week went as simulated
    float team1Total = 0; //results of this week combined with simulation of remaining scores
    float team1Variance = 0;
    for(FBTeamComparisonPlayer *player in [self.team1Players allValues]) {
        for (NSNumber *score in player.scores) {
            team1ProjTotal += player.average;
            if (score.class != [NSNull class]) team1Total += score.intValue;
            else {
                team1Total += player.average;
                team1Variance += player.variance;
            }
        }
    }
    
    float team2ProjTotal = 0;
    float team2Total = 0;
    float team2Variance = 0;
    for(FBTeamComparisonPlayer *player in [self.team2Players allValues]) {
        for (NSNumber *score in player.scores) {
            team2ProjTotal += player.average;
            if (score.class != [NSNull class]) team2Total += score.intValue;
            else {
                team2Total += player.average;
                team2Variance += player.variance;
            }
        }
    }
    
    float sumMean = team1Total - team2Total;
    float sumSTD = sqrt(team1Variance + team2Variance);
    float chance = 0.5 * erfcf((sumMean/sumSTD) * M_SQRT1_2);
    
    self.team1ProjScore = team1Total;
    self.team2ProjScore = team2Total;
    self.team1WinPct = 100-chance*100;
    
    NSLog(@"\nteam 1: %f %f \nteam 2: %f %f \nchance: %f",team1Total,team1Variance,team2Total,team2Variance,self.team1WinPct);
    numStepsFinished ++;
    update(numPlayersFinished + numStepsFinished, numPlayersAnticipated + numStepsAnticipated);
}

@end

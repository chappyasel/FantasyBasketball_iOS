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
    NSURL *url = [NSURL URLWithString:link];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Comparison error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    //table[@class='playerTableTable tableBody']/tr
    NSArray *nodes = [parser searchWithXPathQuery:@"//table[@class='playerTableTable tableBody']/tr"];
    self.team1Players = [[NSMutableDictionary alloc] init];
    self.team2Players = [[NSMutableDictionary alloc] init];
    NSMutableArray *team2Names = [[NSMutableArray alloc] init];
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
            NSString *name = [children[1].children[0] content];
            //if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"])
            //    [dict setObject:[children[1].children[2] content] forKey:@"injury"];
            //[dict setObject:children[3].content forKey:@"isPlaying+gameState+score+status"];
            NSNumber *fpts = [NSNumber numberWithInt:[children[18].content intValue]];
            if (switchValid) switchPoint ++;
            else [team2Names addObject:name];
            if (isStarting) {
                if (!self.team1Players[name]) {
                    FBTeamComparisonPlayer *player = [[FBTeamComparisonPlayer alloc] init];
                    [player loadPlayerWithName:name];
                    [self.team1Players setObject:player forKey:name];
                }
                [self.team1Players[name] addScore:fpts];
            }
        }
        else if (switchPoint != 0) switchValid = NO;
    }
    for (NSString *name in team2Names) {
        [self.team2Players setObject:self.team1Players[name] forKey:name];
        [self.team1Players removeObjectForKey:name];
    }
    update(1,1);
}

@end

//
//  TodayViewController.m
//  Fantasy Basketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "FBSession.h"
#import "FBPlayer.h"
#import "TFHpple.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

FBSession *session;
NSMutableArray *players1;
NSMutableArray *players2;
TFHpple *parser;
UILabel *lastUpdated;
int numSlots = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!session) {
        session = [FBSession sharedInstance];
        session.leagueID = 294156;
        session.teamID = 11;
        session.seasonID = 2015;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/clubhouse?leagueId=%d&teamId=%d&seasonId=%d&version=today",session.leagueID,session.teamID,session.seasonID]];
        NSData *html = [NSData dataWithContentsOfURL:url];
        TFHpple *parser = [TFHpple hppleWithHTMLData:html];
        NSString *XpathQueryString = @"//div[@class='playertablefiltersmenucontainer']/a";
        NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
        NSString *string = [[nodes firstObject] objectForKey:@"onclick"];
        NSRange r = [string rangeOfString:@"scoringPeriodId="];
        int beg = (int)r.length + (int)r.location;
        int end = (int)[string rangeOfString:@"&view="].location;
        session.scoringPeriodID = [[string substringWithRange:NSMakeRange(beg, end-beg)] intValue];
    }
    [self loadplayersMU];
    [self loadTableView];
    [self setPreferredContentSize:CGSizeMake(320, 80+_tableView.frame.size.height)];
    //Score display
    NSString *XpathQueryString = @"//tr[@style='text-align:right; background:#f2f2e8']/td/span";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    _team1Display1.text = [nodes[0] content];
    _team2Display1.text = [nodes[1] content];
    NSString *XpathQueryString2 = @"//div[@style='font-size:18px; margin-bottom:14px; font-family:Helvetica,sans-serif;']/b";
    NSArray *nodes2 = [parser searchWithXPathQuery:XpathQueryString2];
    _team1Display2.text = [nodes2[0] content];
    _team2Display2.text = [nodes2[1] content];
    //reload button
    UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 80+_tableView.frame.size.height)];
    [refresh addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    NSLog(@"DONE");
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    NSLog(@"REFRESH");
    [self loadplayersMU];
    [_tableView reloadData];
    //Last updated
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a, EEE, MMM d"];
    lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@",[dateFormatter stringFromDate: currentTime]];
    NSLog(@"REFRESHED");
}

- (void)loadTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, 40*numSlots+60) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor whiteColor];
    _tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
    _tableView.userInteractionEnabled = NO;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
}

- (void)loadplayersMU {
    int numStarters1 = 0, numStarters2 = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/boxscorefull?leagueId=%d&teamId=%d&scoringPeriodId=%d&seasonId=%d&view=scoringperiod&version=full",session.leagueID,session.teamID,session.scoringPeriodID,session.seasonID]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    players1 = [[NSMutableArray alloc] initWithCapacity:13];
    players2 = [[NSMutableArray alloc] initWithCapacity:13];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:22];
            for (TFHppleElement *stat in element.children) {
                if (![stat.content isEqualToString:@""]) {
                    if ([[stat objectForKey:@"class"] isEqualToString:@"playertablePlayerName"]) {
                        [data addObject: [stat.children[0] content]];
                        [data addObject: [stat.children[1] content]];
                        if (stat.children.count == 4) [data addObject: [stat.children[2] content]];
                        else [data addObject: @""];
                    }
                    else [data addObject: stat.content];
                }
            }
            if (data.count == 17) { //not playing
                [data insertObject:@"--" atIndex:5];
                [data insertObject:@"--" atIndex:6];
            }
            [data insertObject:@"--" atIndex:4]; //type
            [data insertObject:@"--" atIndex:8]; //gs
            [data insertObject:@"--" atIndex:20]; //tot
            [data insertObject:@"--" atIndex:22]; //pct
            [data insertObject:@"--" atIndex:23]; //+/-
            [data addObject:@"--"]; //playerID
            if (i < 13)[players1 addObject:[[FBPlayer alloc] initWithData:data]];
            else [players2 addObject:[[FBPlayer alloc] initWithData:data]];
        }
    }
    NSMutableArray *markForDel1 = [[NSMutableArray alloc] init];
    for (int i = 0; i < players1.count; i++) {
        if([players1[i] isPlaying] && [players1[i] isStarting]) numStarters1 ++;
        else [markForDel1 addObject:[NSNumber numberWithInt:i]];
    }
    for (int i = (int)markForDel1.count-1; i >= 0; i--) [players1 removeObjectAtIndex:[markForDel1[i] integerValue]];
    NSMutableArray *markForDel2 = [[NSMutableArray alloc] init];
    for (int i = 0; i < players2.count; i++) {
        if([players2[i] isPlaying] && [players2[i] isStarting]) numStarters2 ++;
        else [markForDel2 addObject:[NSNumber numberWithInt:i]];
    }
    for (int i = (int)markForDel2.count-1; i >= 0; i--) [players2 removeObjectAtIndex:[markForDel2[i] integerValue]];
    if (numStarters1 > numStarters2) numSlots = numStarters1;
    else numSlots = numStarters2;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numSlots;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    UILabel *background = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 40)];
    background.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    background.layer.cornerRadius = 10.0;
    background.clipsToBounds = YES;
    [cell addSubview:background];
    if (numSlots == 0) { //no players playing
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        label.text = @"No players playing today";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor lightTextColor];
        [cell addSubview:label];
    }
    else {
        //STATS LABELS
        float tot1 = 0;
        float tot2 = 0;
        if (section == 0) {
            for (int i = 0; i < players1.count; i++) {
                FBPlayer *player = players1[i];
                if (player.isPlaying) tot1 += player.fantasyPoints;
            }
            for (int i = 0; i < players2.count; i++) {
                FBPlayer *player = players2[i];
                if (player.isPlaying) tot2 += player.fantasyPoints;
            }
        }
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(160-40, 0, 40, 40)];
        stats.text = [NSString stringWithFormat:@"%.0f",tot1];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:18];
        stats.textColor = [UIColor whiteColor];
        [cell addSubview:stats];
        UILabel *stats2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 40, 40)];
        stats2.text = [NSString stringWithFormat:@"%.0f",tot2];
        stats2.textAlignment = NSTextAlignmentCenter;
        stats2.font = [UIFont boldSystemFontOfSize:18];
        stats2.textColor = [UIColor whiteColor];
        [cell addSubview:stats2];
    }
    lastUpdated = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 290, 20)];
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a, EEE, MMM d"];
    lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@",[dateFormatter stringFromDate: currentTime]];
    lastUpdated.font = [UIFont systemFontOfSize:11];
    lastUpdated.textAlignment = NSTextAlignmentCenter;
    lastUpdated.textColor = [UIColor lightTextColor];
    [cell addSubview:lastUpdated];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    if (players1.count-1 >= indexPath.row) {
        FBPlayer *player = players1[indexPath.row];
        if (player.isPlaying) {
            //NAME
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 25)];
            name.text = [NSString stringWithFormat:@"%@. %@",[player.firstName substringToIndex:1],player.lastName];
            name.textColor = [UIColor whiteColor];
            [cell addSubview:name];
            //Subname
            UILabel *subName = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 120, 20)];
            subName.font = [subName.font fontWithSize:10];
            subName.lineBreakMode = NSLineBreakByTruncatingHead;
            subName.textColor = [UIColor lightTextColor];
            if (player.gameInProgress || player.gameEnded) subName.text = [NSString stringWithFormat:@"%@, %@ %@: %.0f + %.0f",player.opponent,player.score,player.status, player.points-(player.fta-player.ftm)-(player.fga-player.fgm), player.rebounds+player.assists+player.blocks+player.steals-player.turnovers];
            else subName.text = [NSString stringWithFormat:@"%@, %@",player.opponent,player.status];
            [cell addSubview:subName];
            //Points
            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(160-40, 0, 40, 40)];
            if (!player.isPlaying) stats.text = @"-";
            else stats.text = [NSString stringWithFormat:@"%.0f",player.fantasyPoints];
            stats.textAlignment = NSTextAlignmentCenter;
            stats.font = [UIFont boldSystemFontOfSize:18];
            stats.textColor = [UIColor whiteColor];
            [cell addSubview:stats];
        }
    }
    if (players2.count-1 >= indexPath.row) {
        FBPlayer *player = players2[indexPath.row];
        if (player.isPlaying) {
            //NAME
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(320-120, 0, 120, 25)];
            name.text = [NSString stringWithFormat:@"%@. %@",[player.firstName substringToIndex:1],player.lastName];
            name.textColor = [UIColor whiteColor];
            name.textAlignment = NSTextAlignmentRight;
            [cell addSubview:name];
            //Subname
            UILabel *subName = [[UILabel alloc] initWithFrame:CGRectMake(320-120, 18, 120, 20)];
            subName.font = [subName.font fontWithSize:10];
            subName.lineBreakMode = NSLineBreakByTruncatingTail;
            subName.textColor = [UIColor lightTextColor];
            subName.textAlignment = NSTextAlignmentRight;
            if (player.gameInProgress || player.gameEnded) subName.text = [NSString stringWithFormat:@"%.0f + %.0f :%@ %@, %@", player.points-(player.fta-player.ftm)-(player.fga-player.fgm), player.rebounds+player.assists+player.blocks+player.steals-player.turnovers,player.status,player.score, player.opponent];
            else subName.text = [NSString stringWithFormat:@"%@, %@",player.status,player.opponent];
            [cell addSubview:subName];
            //Points
            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 40, 40)];
            if (!player.isPlaying) stats.text = @"-";
            else stats.text = [NSString stringWithFormat:@"%.0f",player.fantasyPoints];
            stats.textAlignment = NSTextAlignmentCenter;
            stats.font = [UIFont boldSystemFontOfSize:18];
            stats.textColor = [UIColor whiteColor];
            [cell addSubview:stats];
        }
    }
    return cell;
}

#pragma mark - other

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self refreshButtonPressed:nil];
    completionHandler(NCUpdateResultNewData);
}

@end

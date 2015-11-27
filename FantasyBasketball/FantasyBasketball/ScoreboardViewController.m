//
//  ScoreboardViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "ScoreboardViewController.h"

@interface ScoreboardViewController ()

@property NSMutableArray *leagueScoreboard; //name, abbreviation, record, manager, score, teamLink (matchupLink)
@property NSMutableArray *NBAScoreboard; //status, tv, teams -> (abbreviation, image, name, score)

@property BOOL isInLeagueMode;

@end

@implementation ScoreboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scoreboard";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.isInLeagueMode = YES;
    [self beginAsyncLoading];
}

- (void)beginAsyncLoading {
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self loadLeagueScoreboardWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isInLeagueMode) [self.tableView reloadData];
            });
        }];
        [self loadNBAScoreboardWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.isInLeagueMode) [self.tableView reloadData];
            });
        }];
    });
}

- (void)loadLeagueScoreboardWithCompletionBlock:(void (^)(void)) completed {
    self.leagueScoreboard = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/scoreboard?leagueId=%@&seasonId=%@",self.session.leagueID,self.session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Scoreboard error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//div[@id='scoreboardMatchups']/div/table/tr/td/table"];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *matchupElement = nodes[i];
        NSMutableArray *matchup = [[NSMutableArray alloc] init];
        for (int t = 0; t < 2; t++) {
            NSMutableDictionary *teamDict = [[NSMutableDictionary alloc] init];
            TFHppleElement *team = matchupElement.children[t];
            teamDict[@"score"] = [team.children[1] content];
            NSArray *nameAbbrev = [team.firstChild.firstChild.content componentsSeparatedByString:@" "];
            NSString *name = nameAbbrev[0];
            for (int i = 1; i < nameAbbrev.count-1; i++) name = [NSString stringWithFormat:@"%@ %@",name,nameAbbrev[i]];
            teamDict[@"name"] = name;
            teamDict[@"abbreviation"] = [[nameAbbrev[nameAbbrev.count-1] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            NSArray *recordManager = [[[team.firstChild.children[1] content] stringByReplacingOccurrencesOfString:@")" withString:@" "] componentsSeparatedByString:@" "];
            NSString *manager = recordManager[1];
            for (int i = 2; i < recordManager.count; i++) manager = [NSString stringWithFormat:@"%@ %@",manager,recordManager[i]];
            teamDict[@"manager"] = manager;
            teamDict[@"record"] = [recordManager[0] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            [matchup addObject:teamDict];
        }
        [self.leagueScoreboard addObject:matchup];
    }
    completed();
}

- (void)loadNBAScoreboardWithCompletionBlock:(void (^)(void)) completed {
    self.NBAScoreboard = [[NSMutableArray alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyymmdd"];
    NSDate *date = [NSDate date];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nba.com/gameline/%@/",@"20151125"]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Scoreboard error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray <TFHppleElement *> *nodes = [parser searchWithXPathQuery:@"//div[@id='nbaSSOuter']/div/div"];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *gameInfo = nodes[i].firstChild.firstChild.firstChild;
        TFHppleElement *gameStatus = [nodes[i].firstChild.firstChild children][3];
        NSString *liveStatus = [gameStatus.firstChild.firstChild.children[1] content];
        NSString *image = [gameStatus.firstChild.children[1] firstChild].firstChild.attributes[@"src"];
        image = [NSString stringWithFormat:@"%@%@",@"http://www.nba.com",image];
        NSArray *teamsElements = [gameStatus.firstChild.children[2] children];
        NSMutableArray *teams = [[NSMutableArray alloc] init];
        for (int e = 0; e < teamsElements.count; e++) {
            TFHppleElement *t = teamsElements[e];
            NSString *abbrev = t.firstChild.content;
            NSString *teamImage = [(TFHppleElement *)t.children[1] attributes][@"src"];
            NSString *name = [(TFHppleElement *)t.children[1] attributes][@"title"];
            TFHppleElement *scoreRow = [gameStatus.children[1] firstChild].children[e+1];
            [teams addObject:[[NSDictionary alloc] initWithObjects:@[abbrev, teamImage, name, scoreRow] forKeys:@[@"abbreviation",@"image",@"name",@"score"]]];
        }
        TFHppleElement *actionRow = [nodes[i].children[1] firstChild];
        [self.NBAScoreboard addObject:[[NSDictionary alloc] initWithObjects:@[teams, image, liveStatus] forKeys:@[@"teams", @"tv", @"status"]]];
    }
    completed();
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isInLeagueMode) return self.leagueScoreboard.count;
    return self.NBAScoreboard.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isInLeagueMode) return 120;
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    float width = self.view.frame.size.width;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    cell = nil; //temporary
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Identifier"];
    }
    if (self.isInLeagueMode) {
        NSArray <NSDictionary *> *matchup = self.leagueScoreboard[indexPath.row];
        //background
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(10, 5, width-20, 120-10)];
        background.backgroundColor = [UIColor FBMediumOrangeColor];
        background.layer.cornerRadius = 5;
        [cell addSubview:background];
        //left name
        UILabel *leftName = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, (width-20)/2-10, 30)];
        leftName.text = matchup[0][@"name"];
        leftName.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        leftName.textAlignment = NSTextAlignmentCenter;
        leftName.textColor = [UIColor whiteColor];
        leftName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:leftName];
        //left subname
        UILabel *leftSName = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, (width-20)/2-10, 20)];
        leftSName.text = [NSString stringWithFormat:@"%@ (%@)",matchup[0][@"manager"],matchup[0][@"record"]];
        leftSName.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        leftSName.textAlignment = NSTextAlignmentCenter;
        leftSName.textColor = [UIColor whiteColor];
        leftSName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:leftSName];
        //left score
        UILabel *leftScore = [[UILabel alloc] initWithFrame:CGRectMake(5, 55, (width-20)/2-10, 40)];
        leftScore.text = matchup[0][@"score"];
        leftScore.font = [UIFont systemFontOfSize:40 weight:UIFontWeightRegular];
        leftScore.textAlignment = NSTextAlignmentCenter;
        leftScore.textColor = [UIColor whiteColor];
        leftScore.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:leftScore];
        //right name
        UILabel *rightName = [[UILabel alloc] initWithFrame:CGRectMake(width-(width-20)/2-10-5, 5, (width-20)/2-10, 30)];
        rightName.text = matchup[1][@"name"];
        rightName.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        rightName.textAlignment = NSTextAlignmentCenter;
        rightName.textColor = [UIColor whiteColor];
        rightName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:rightName];
        //right subname
        UILabel *rightSName = [[UILabel alloc] initWithFrame:CGRectMake(width-(width-20)/2-10-5, 30, (width-20)/2-10, 20)];
        rightSName.text = [NSString stringWithFormat:@"%@ (%@)",matchup[1][@"manager"],matchup[1][@"record"]];
        rightSName.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        rightSName.textAlignment = NSTextAlignmentCenter;
        rightSName.textColor = [UIColor whiteColor];
        rightSName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:rightSName];
        //right score
        UILabel *rightScore = [[UILabel alloc] initWithFrame:CGRectMake(width-(width-20)/2-10-5, 55, (width-20)/2-10, 40)];
        rightScore.text = matchup[1][@"score"];
        rightScore.font = [UIFont systemFontOfSize:40 weight:UIFontWeightRegular];
        rightScore.textAlignment = NSTextAlignmentCenter;
        rightScore.textColor = [UIColor whiteColor];
        rightScore.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:rightScore];
    }
    else {
        
    }
    return cell;
}

#pragma mark - segmented control actions

- (IBAction)scoreboardModeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) self.isInLeagueMode = YES;
    else self.isInLeagueMode = NO;
    [self.tableView reloadData];
}

#pragma mark - other links

- (void)linkWithWebLink:(NSString *)link {
    WebViewController *modalVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"w"];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    modalVC.link = link;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = YES;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.9;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:modalVC.webView.scrollView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

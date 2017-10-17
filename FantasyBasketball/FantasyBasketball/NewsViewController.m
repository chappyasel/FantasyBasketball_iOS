//
//  NewsViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "NewsViewController.h"
#import "WebViewController.h"
#import "MyTeamViewController.h"
#import "TFHpple.h"
#import "FBPlayer.h"

@interface NewsViewController ()

//@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;
@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic) NSMutableArray *generalNews;
@property (nonatomic) NSMutableArray *transactions;
@property (nonatomic) NSMutableArray __block *playerNews; //team and WL

@property int numTeamPlayersLoaded; //out of 13 (for section header)
@property int numWLPlayersLoaded;

@property BOOL isLarge;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News";
    self.newsSettings = [FBNewsSettings fetchNewsSettings];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = YES;
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageOperationQueue.maxConcurrentOperationCount = 4;
    self.imageCache = [[NSCache alloc] init];
    self.isLarge = (self.view.frame.size.width > 400);
    [self beginAsyncLoading];
}

- (void)beginAsyncLoading {
    self.playerNews = [[NSMutableArray alloc] init];
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self loadGeneralFantasyNewsWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        [self loadTransactionsWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        [self loadTeamNewsWithCompletionBlock:^(int numCompleted) {
            //sort by time
            self.playerNews = [[NSMutableArray alloc] initWithArray:[self.playerNews sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2) {
                NSDate *date1 = d1[@"date"];
                NSDate *date2 = d2[@"date"];
                return [date2 compare:date1]; //newest first
            }]];
            NSLog(@"%ld",self.playerNews.count);
            self.numTeamPlayersLoaded = numCompleted;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        [self loadWLNewsWithCompletionBlock:^(int numCompleted) {
            //sort by time
            self.playerNews = [[NSMutableArray alloc] initWithArray:[self.playerNews sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2) {
                NSDate *date1 = d1[@"date"];
                NSDate *date2 = d2[@"date"];
                return [date2 compare:date1]; //newest first
            }]];
            self.numWLPlayersLoaded = numCompleted;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    });
}

- (void)loadTeamNewsWithCompletionBlock:(void (^)(int numCompleted)) completed {
    //load team
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.com/fba/clubhouse?leagueId=%@&teamId=%@&seasonId=%@&version=today&scoringPeriodId=%@",self.session.leagueID,self.session.teamID,self.session.seasonID,self.session.scoringPeriodID]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//table[@class='playerTableTable tableBody']/tr"];
    for (int i = 2; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSString *nameString = ((TFHppleElement *)element.children[1]).firstChild.content;
            NSDictionary *name = [FBPlayer separateFirstAndLastNameForString:nameString];
            [names addObject:@[name[@"first"], name[@"last"]]];
        }
    }
    int __block i = 0;
    for (NSArray *name in names) {
        dispatch_async(dispatch_queue_create("Queue",NULL), ^{
            [self loadRotoworldWithName:name isOnWL:NO completionBlock:^(NSArray<NSDictionary *> *news) {
                [self.playerNews addObjectsFromArray:news];
                i++;
                completed(i);
            }];
        });
    }
}

- (void)loadWLNewsWithCompletionBlock:(void (^)(int numCompleted))completed {
    int __block i = 0;
    for (NSString *nameString in self.watchList.playerArray) {
        dispatch_async(dispatch_queue_create("Queue",NULL), ^{
            NSDictionary *name = [FBPlayer separateFirstAndLastNameForString:nameString];
            [self loadRotoworldWithName:@[name[@"first"], name[@"last"]] isOnWL:YES completionBlock:^(NSArray<NSDictionary *> *news) {
                [self.playerNews addObjectsFromArray:news];
                i++;
                completed(i);
            }];
        });
    }
}

- (void)loadRotoworldWithName:(NSArray *)name isOnWL:(BOOL)isOnWL completionBlock:(void (^)(NSArray <NSDictionary *> *news))completed {
    NSMutableArray <NSDictionary *> *news = [[NSMutableArray alloc] init];
    TFHpple *statParser = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.rotoworld.com/content/playersearch.aspx?searchname=%@,%@&sport=nba",name[1],name[0]]]]];
    NSString *rotoworldLink = [[[statParser searchWithXPathQuery:@"//div[@class='moreplayernews']/a"] firstObject] objectForKey:@"href"];
    TFHpple *rotoParser = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.rotoworld.com%@",rotoworldLink]]]];
    NSArray <TFHppleElement *> *elements = [rotoParser searchWithXPathQuery:@"//div[@class='pp']/div[@class='playernews']"];
    for (TFHppleElement *element in elements) {
        NSMutableDictionary *rotoPeice = [[NSMutableDictionary alloc] init];
        for (TFHppleElement *c in element.children) {
            if ([[c objectForKey:@"class"] isEqualToString:@"report"]) {
                NSString *tmp = [c.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"  " withString:@""];
                [rotoPeice setObject:tmp forKey:@"report"];
            }
            if ([[c objectForKey:@"class"] isEqualToString:@"impact"]) {
                NSString *tmp = [c.firstChild.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"  " withString:@""];
                [rotoPeice setObject:tmp forKey:@"impact"];
                NSString *dateString = [c.children[1] content];
                NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc] init];
                [currentDateFormatter setDateFormat:@" yyyy"];
                dateString = [dateString stringByAppendingString:[currentDateFormatter stringFromDate:[NSDate date]]];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMM dd - h:mm a yyyy"];
                NSDate *date = [dateFormatter dateFromString:dateString];
                if (date) [rotoPeice setObject:date forKey:@"date"];
            }
        }
        [rotoPeice setObject:[NSString stringWithFormat:@"%@ %@",name[0],name[1]] forKey:@"name"];
        if (isOnWL) [rotoPeice setObject:@1 forKey:@"isOnWL"];
        else [rotoPeice setObject:@0 forKey:@"isOnWL"];
        [news addObject:rotoPeice];
    }
    completed(news);
}

- (void)loadGeneralFantasyNewsWithCompletionBlock:(void (^)(void)) completed {
    self.generalNews = [[NSMutableArray alloc] initWithCapacity:13];
    NSURL *url = [NSURL URLWithString:@"http://www.cbssports.com/fantasy/basketball/"];
    NSData *html = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    TFHppleElement *firstItem = [parser searchWithXPathQuery:@"//div[@class='marquee']"].firstObject; //first news item
    if (((TFHppleElement *)firstItem.children[1]).children.count != 0 && firstItem.children.count > 3) {
        NSString *imageLink = [((TFHppleElement *)((TFHppleElement *)firstItem.children[1]).children[1]).attributes valueForKey:@"src"];
        NSString *title = ((TFHppleElement *)((TFHppleElement *)firstItem.children[3]).children[1]).content;
        NSString *link = [((TFHppleElement *)((TFHppleElement *)firstItem.children[3]).children[1]).firstChild.attributes valueForKey:@"href"];
        link = [NSString stringWithFormat:@"%@%@",@"http://www.cbssports.com",link];
        [self.generalNews addObject:[[NSDictionary alloc] initWithObjects:@[imageLink, title, link] forKeys:@[@"image", @"title", @"link"]]];
    }
    NSArray <TFHppleElement *> *otherItems = [parser searchWithXPathQuery:@"//ul[@id='latest-stream-listing']/div/li"]; //rest of news items
    for (int i = 0; i < otherItems.count; i++) {
        TFHppleElement *newsItem = otherItems[i];
        if (newsItem.attributes.count == 0) { //not an ad
            if (((TFHppleElement *)newsItem.children[1]).children.count != 0 && newsItem.children.count > 3) {
                NSString *imageLink = [((TFHppleElement *)((TFHppleElement *)newsItem.children[1]).children[1]).firstChild.attributes valueForKey:@"src"];
                NSString *title = ((TFHppleElement *)((TFHppleElement *)newsItem.children[3]).children[3]).content;
                NSString *link = [((TFHppleElement *)newsItem.children[1]).attributes valueForKey:@"href"];
                link = [NSString stringWithFormat:@"%@%@",@"http://www.cbssports.com",link];
                [self.generalNews addObject:[[NSDictionary alloc] initWithObjects:@[imageLink, title, link] forKeys:@[@"image", @"title", @"link"]]];
            }
        }
    }
    completed();
}

- (void)loadTransactionsWithCompletionBlock:(void (^)(void)) completed {
    self.transactions = [[NSMutableArray alloc] init];
    NSDate *endDate = [NSDate date];
    NSDate *sevenDaysAgo = [endDate dateByAddingTimeInterval:-7*24*60*60];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://games.espn.com/fba/recentactivity?leagueId=%@&seasonId=%@&activityType=2&startDate=%@&endDate=%@&teamId=-1&tranType=-2",self.session.leagueID,self.session.seasonID,[dateFormatter stringFromDate:sevenDaysAgo],[dateFormatter stringFromDate:endDate]]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray <TFHppleElement *> *transactions = [parser searchWithXPathQuery:@"//table[@class='tableBody']/tr"];
    for (int i = 2; i < transactions.count; i++) {
        TFHppleElement *transaction = transactions[i];
        NSString *image = ((TFHppleElement *)transaction.children[1]).firstChild[@"src"];
        NSString *dateString = [NSString stringWithFormat:@"%@ %@",transaction.firstChild.firstChild.content,((TFHppleElement *)transaction.firstChild.children[2]).content];
        NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc] init];
        [currentDateFormatter setDateFormat:@" yyyy"];
        dateString = [dateString stringByAppendingString:[currentDateFormatter stringFromDate:[NSDate date]]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EE, MMM dd h:mm a yyyy"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        NSDate *date = [dateFormatter dateFromString: dateString];
        NSString *action = ((TFHppleElement *)transaction.children[1]).content;
        action = [action stringByReplacingOccurrencesOfString:@"  " withString:@" - "]; //need to make this work
        NSString *detail = ((TFHppleElement *)transaction.children[2]).content;
        NSString *link = ((TFHppleElement *)transaction.children[3]).firstChild.attributes[@"href"];
        link = [NSString stringWithFormat:@"%@%@",@"http://games.espn.com",link];
        [self.transactions addObject:[[NSDictionary alloc] initWithObjects:@[date, action, detail, link, image] forKeys:@[@"date",@"title",@"text",@"link",@"image"]]];
    }
    completed();
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSDictionary *newsPeice = self.generalNews[indexPath.row];
        if (newsPeice[@"link"]) [self linkWithWebLink:newsPeice[@"link"]];
    }
    else if (indexPath.section == 1) {
        NSDictionary *transaction = self.transactions[indexPath.row];
        if (transaction[@"link"]) [self linkWithTeamLink:transaction[@"link"]];
    }
    else if (indexPath.section == 2) {
        NSDictionary *teamNewsRow = self.playerNews[indexPath.row];
        NSDictionary *name = [FBPlayer separateFirstAndLastNameForString:teamNewsRow[@"name"]];
        [self linkWithPlayerName:[[NSDictionary alloc] initWithObjects:@[name[@"first"], name[@"last"]] forKeys:@[@"first", @"last"]]];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.generalNews.count;
    if (section == 1) return self.transactions.count;
    if (section == 2) return self.playerNews.count;
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"CBS Fantasy News";
    if (section == 1) return @"League Transactions";
    if (section == 2 && self.isLarge) {
        if (self.numTeamPlayersLoaded == 13 && self.numWLPlayersLoaded == self.watchList.playerArray.count) return @"Rotoworld Team & WL News";
        return [NSString stringWithFormat:@"Rotoworld Team & WL News (%d/%d, %d/%ld)",self.numTeamPlayersLoaded,13,self.numWLPlayersLoaded,self.watchList.playerArray.count];
    }
    else if (section == 2) {
        if (self.numTeamPlayersLoaded == 13 && self.numWLPlayersLoaded == self.watchList.playerArray.count) return @"Rotoworld News";
        return [NSString stringWithFormat:@"Rotoworld News (%d/%d, %d/%ld)",self.numTeamPlayersLoaded,13,self.numWLPlayersLoaded,self.watchList.playerArray.count];
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.newsSettings.selectorDataArray[0].boolValue) return 100;
    else if (indexPath.section == 1 && self.newsSettings.selectorDataArray[1].boolValue) return 90;
    else if (indexPath.section == 2 && (self.newsSettings.selectorDataArray[2].boolValue || self.newsSettings.selectorDataArray[3].boolValue)) {
        NSDictionary *rotoPeice = self.playerNews[indexPath.row];
        if ([rotoPeice[@"isOnWL"] isEqual: @1]) { if (!self.newsSettings.selectorDataArray[3].boolValue) return 0; }
        else { if (!self.newsSettings.selectorDataArray[2].boolValue) return 0; }
        NSString *text = [NSString stringWithFormat:@"%@ %@",[self.playerNews[indexPath.row] objectForKey:@"report"],[self.playerNews[indexPath.row] objectForKey:@"impact"]];
        UIFont *font = [UIFont systemFontOfSize:15];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@ {NSFontAttributeName: font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width-20.0, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return (CGFloat)rect.size.height+30+35;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    cell = nil; //temporary
    float width = self.view.frame.size.width;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Identifier"];
    }
    if (indexPath.section == 0) {
        if (!self.newsSettings.selectorDataArray[0].boolValue) return cell;
        NSDictionary *newsPeice = self.generalNews[indexPath.row];
        //title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, width-160, 80)];
        titleLabel.text = newsPeice[@"title"];
        titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
        titleLabel.numberOfLines = 2;
        [cell addSubview:titleLabel];
        //image
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 80)];
        image.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *imageFromCache = [self.imageCache objectForKey:[newsPeice objectForKey:@"image"]];
        if (imageFromCache) image.image = imageFromCache;
        else {
            [self.imageOperationQueue addOperationWithBlock:^{
                NSURL *imageurl = [NSURL URLWithString:[newsPeice objectForKey:@"image"]];
                UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];
                if (img != nil) {
                    [self.imageCache setObject:img forKey:[newsPeice objectForKey:@"image"]];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        UITableViewCell *updateCell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            image.image = img;
                            [updateCell addSubview:image];
                        }
                    }];
                }
            }];
        }
        //image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:]]];
        [cell addSubview:image];
    }
    else if (indexPath.section == 1) {
        if (!self.newsSettings.selectorDataArray[1].boolValue) return cell;
        NSDictionary *transaction = self.transactions[indexPath.row];
        //title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, width-65, 25)];
        titleLabel.text = transaction[@"title"];
        titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
        [cell addSubview:titleLabel];
        //text
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, width-65, 35)];
        textLabel.text = transaction[@"text"];
        textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.numberOfLines = 2;
        [cell addSubview:textLabel];
        //date
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 70, width-65, 15)];
        NSDate *date = transaction[@"date"];
        dateLabel.text = [self calculateTimeAgoWithDate:date];
        dateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:dateLabel];
        //image
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 27.5, 35, 35)];
        image.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *imageFromCache = [self.imageCache objectForKey:[transaction objectForKey:@"image"]];
        if (imageFromCache) image.image = imageFromCache;
        else {
            [self.imageOperationQueue addOperationWithBlock:^{
                NSURL *imageurl = [NSURL URLWithString:[transaction objectForKey:@"image"]];
                UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];
                if (img != nil) {
                    [self.imageCache setObject:img forKey:[transaction objectForKey:@"image"]];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        UITableViewCell *updateCell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            image.image = img;
                            [updateCell addSubview:image];
                        }
                    }];
                }
            }];
        }
        //image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:]]];
        [cell addSubview:image];
    }
    else if (indexPath.section == 2) {
        NSDictionary *rotoPeice = self.playerNews[indexPath.row];
        if ([rotoPeice[@"isOnWL"] isEqual: @1]) { if (!self.newsSettings.selectorDataArray[3].boolValue) return cell; }
        else { if (!self.newsSettings.selectorDataArray[2].boolValue) return cell; }
        float height = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
        //name
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, width-20, 30)];
        if ([rotoPeice[@"isOnWL"] isEqual: @1]) name.text = [NSString stringWithFormat:@"%@ - Watch List",rotoPeice[@"name"]];
        else name.text = [NSString stringWithFormat:@"%@ - My Team",rotoPeice[@"name"]];
        name.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
        [cell addSubview:name];
        //text
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, width-20, height-25-30)];
        text.text = [NSString stringWithFormat:@"%@ %@",[rotoPeice objectForKey:@"report"],[rotoPeice objectForKey:@"impact"]];
        text.font = [UIFont systemFontOfSize:15];
        text.textColor = [UIColor darkGrayColor];
        text.numberOfLines = (int)(text.frame.size.height/text.font.lineHeight);
        [cell addSubview:text];
        //time
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(50, height-20, width-60, 15)];
        NSDate *date = [rotoPeice objectForKey:@"date"];
        time.text = [self calculateTimeAgoWithDate:date];
        time.textColor = [UIColor lightGrayColor];
        time.font = [UIFont systemFontOfSize:13];
        time.textAlignment = NSTextAlignmentRight;
        [cell addSubview:time];
    }
    //cell.delegate = self;
    return cell;
}

- (NSString *)calculateTimeAgoWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date toDate:[NSDate date] options:0];
    NSString *time;
    if(components.month != 0) {
        if(components.month == 1) time = [NSString stringWithFormat:@"%ld month",(long)components.month];
        else time = [NSString stringWithFormat:@"%ld months",(long)components.month];
    }
    else if(components.day != 0) {
        if(components.day == 1) time = [NSString stringWithFormat:@"%ld day",(long)components.day];
        else time = [NSString stringWithFormat:@"%ld days",(long)components.day];
    }
    else if(components.hour != 0) {
        if(components.hour == 1) time = [NSString stringWithFormat:@"%ld hour",(long)components.hour];
        else time = [NSString stringWithFormat:@"%ld hours",(long)components.hour];
    }
    else if(components.minute != 0) {
        if(components.minute == 1) time = [NSString stringWithFormat:@"%ld min",(long)components.minute];
        else time = [NSString stringWithFormat:@"%ld mins",(long)components.minute];
    }
    return [NSString stringWithFormat:@"%@ ago",time];
}

#pragma mark - other links

- (void)linkWithPlayerName:(NSDictionary *)playerName { //@"first", @"last"
    PlayerViewController *modalVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"p"];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    modalVC.playerFirstName = playerName[@"first"];
    modalVC.playerLastName = playerName[@"last"];
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = YES;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.9;
    self.animator.transitionDuration = 0.3;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:modalVC.bottomScrollView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

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

- (void)linkWithTeamLink:(NSString *)link {
    MyTeamViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mt"];
    [vc initWithTeamLink:link];
    UINavigationController *modalVC = [[UINavigationController alloc] initWithRootViewController:vc];
    modalVC.navigationBar.barTintColor = [UIColor FBDarkOrangeColor];
    modalVC.navigationBar.tintColor = [UIColor whiteColor];
    modalVC.navigationBar.translucent = NO;
    modalVC.navigationBar.barStyle = UIBarStyleBlack;
    [modalVC.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.9;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:vc.tableView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}


#pragma mark - FBPickerView delegate

- (void)fadeOutWithPickerView:(FBNewsSelectorView *)selectorView { }

-(void) fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBNewsSelectorView *selector = [FBNewsSelectorView loadViewFromNib];
    selector.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    selector.delegate = self;
    [selector resetValues];
    [selector setValuesForAllRows:self.newsSettings.selectorDataArray];
    [selector setAlpha:0.0];
    [self.view addSubview:selector];
    [UIView animateWithDuration:0.25 animations:^{
        [selector setAlpha:1.0];
    } completion: nil];
}

-(void)fadeOutWithSelectorView: (FBNewsSelectorView *) selectorView {
    [UIView animateWithDuration:0.2 animations:^{
        [selectorView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [selectorView removeFromSuperview];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}
- (void)doneButtonPressedInSelectorView:(FBNewsSelectorView *)selectorView {
    self.newsSettings.selectorDataArray = [[NSMutableArray alloc] initWithArray:[selectorView valuesForAllRows]];
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    if (![context save:&error]) NSLog(@"failed to save in NewsView: %@", [error localizedDescription]);
    [self.tableView reloadData];
    [self fadeOutWithSelectorView:selectorView];
}

- (void)cancelButtonPressedInSelectorView:(FBNewsSelectorView *)selectorView {
    [self fadeOutWithSelectorView:selectorView];
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

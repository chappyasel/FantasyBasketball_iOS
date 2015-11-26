//
//  NewsViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "NewsViewController.h"
#import "TFHpple.h"

@interface NewsViewController ()

//@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;
@property (nonatomic, strong) NSCache *imageCache;

@property NSMutableArray *generalNews;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News";
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageOperationQueue.maxConcurrentOperationCount = 4;
    self.imageCache = [[NSCache alloc] init];
    [self loadGeneralFantasyNews];
    [self.tableView reloadData];
}

- (void)loadTeamNews {
    //load team
    //load news player-by-player
}

- (void)loadWatchListNews {
    //load watch list
    //load news player-by-player
}

- (void)loadGeneralFantasyNews {
    //find online
    self.generalNews = [[NSMutableArray alloc] initWithCapacity:13];
    NSURL *url = [NSURL URLWithString:@"http://www.cbssports.com/fantasy/basketball/"];
    NSData *html = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    TFHppleElement *firstItem = [parser searchWithXPathQuery:@"//div[@class='marquee']"].firstObject; //first news item
    NSString *imageLink = [((TFHppleElement *)((TFHppleElement *)firstItem.children[1]).children[1]).attributes valueForKey:@"src"];
    NSString *title = ((TFHppleElement *)((TFHppleElement *)firstItem.children[3]).children[1]).content;
    NSString *link = [((TFHppleElement *)((TFHppleElement *)firstItem.children[3]).children[1]).firstChild.attributes valueForKey:@"href"];
    [self.generalNews addObject:[[NSDictionary alloc] initWithObjects:@[imageLink, title, link] forKeys:@[@"img", @"title", @"link"]]];
    NSArray <TFHppleElement *> *otherItems = [parser searchWithXPathQuery:@"//ul[@id='latest-stream-listing']/div/li"]; //rest of news items
    for (int i = 0; i < otherItems.count; i++) {
        TFHppleElement *newsItem = otherItems[i];
        if (newsItem.attributes.count == 0) { //not an ad
            NSString *imageLink = [((TFHppleElement *)((TFHppleElement *)newsItem.children[1]).children[1]).firstChild.attributes valueForKey:@"src"];
            NSString *title = ((TFHppleElement *)((TFHppleElement *)newsItem.children[3]).children[3]).content;
            NSString *link = [((TFHppleElement *)newsItem.children[1]).attributes valueForKey:@"href"];
            [self.generalNews addObject:[[NSDictionary alloc] initWithObjects:@[imageLink, title, link] forKeys:@[@"img", @"title", @"link"]]];
        }
    }
}

- (void)loadTransactions {
    //find online
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *newsPeice = self.generalNews[indexPath.row];
    if (newsPeice[@"link"]) {
        [self linkWithWebLink:newsPeice[@"link"]];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.generalNews.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (true) return 100;
    return 40;
    //determine hieght of cell
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    cell = nil; //temporary
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Identifier"];
    }
    if (true) {
        NSDictionary *newsPeice = self.generalNews[indexPath.row];
        //title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, self.view.frame.size.width-160, 80)];
        titleLabel.text = newsPeice[@"title"];
        titleLabel.font = [UIFont systemFontOfSize:21 weight:UIFontWeightMedium];
        titleLabel.numberOfLines = 2;
        [cell addSubview:titleLabel];
        //image
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 80)];
        image.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *imageFromCache = [self.imageCache objectForKey:[newsPeice objectForKey:@"img"]];
        if (imageFromCache) image.image = imageFromCache;
        else {
            [self.imageOperationQueue addOperationWithBlock:^{
                NSURL *imageurl = [NSURL URLWithString:[newsPeice objectForKey:@"img"]];
                UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];
                if (img != nil) {
                    [self.imageCache setObject:img forKey:[newsPeice objectForKey:@"img"]];
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
    //cell.delegate = self;
    return cell;
}

#pragma mark - other link

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
    [self.animator setContentScrollView:modalVC.webDisplay.scrollView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
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

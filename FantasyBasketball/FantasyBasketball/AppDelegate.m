//
//  AppDelegate.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "AppDelegate.h"
#import "FBSession.h"
#import "TFHpple.h"
#import "ViewDeckViewController.h"
#import "MatchupViewController.h"
#import "LeftSideMenuViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

FBSession *session;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    session = [FBSession sharedInstance];
    session.leagueID = 186088;
    session.teamID = 1;
    session.seasonID = 2016;
    
    //OLD SCORINGPERIODID METHOD
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/clubhouse?leagueId=%d&teamId=%d&seasonId=%d",session.leagueID,session.teamID,session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"%@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//script";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    for (TFHppleElement *node in nodes) {
        if ([node.content containsString:@"scoringPeriodId"]) {
            NSString *content = node.content;
            NSRange r = [content rangeOfString:@"scoringPeriodId: "];
            int beg = (int)r.length + (int)r.location;
            int end = (int)[content rangeOfString:@",\n\t\tcurrentScoringPeriodId:"].location;
            session.scoringPeriodID = [[content substringWithRange:NSMakeRange(beg, end-beg)] intValue];
            break;
        }
    }
    if (session.scoringPeriodID == 0) NSLog(@"scoringPeriodID is 0, probable error");
    
    /* //POSSIBLE NEW METHOD
    NSString *dateString = @"03-Sep-14";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yy";
    NSDate *refDate = [dateFormatter dateFromString:dateString];
    session.scoringPeriodID = (int)[self daysBetweenDate:refDate andDate:[NSDate date]];
    */
    
    //RESideMenu init
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:[[MatchupViewController alloc] init]]
                                                                    leftMenuViewController:[[LeftSideMenuViewController alloc] init]
                                                                   rightMenuViewController:nil];
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"StadiumBlur.jpg"];
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    self.window.rootViewController = sideMenuViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate, *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    //NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
    //NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
    //NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
    //NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end

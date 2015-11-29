//
//  AppDelegate.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "FBSession.h"
#import "FBWatchList.h"
#import "TFHpple.h"
#import "ViewDeckViewController.h"
#import "MatchupViewController.h"
#import "LeftSideMenuViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FBSession" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSMutableArray <FBSession *> *result = [[NSMutableArray alloc] initWithArray:
                                            [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    }
    else if (result.count == 0) {
        NSLog(@"No sessions, creating exmaples");
        NSManagedObjectContext *context = [self managedObjectContext];
        FBSession *session1 = [NSEntityDescription insertNewObjectForEntityForName:@"FBSession" inManagedObjectContext:context];
        session1.name = @"Chap Squad";
        session1.leagueID = [NSNumber numberWithInt: 186088];
        session1.teamID = [NSNumber numberWithInt: 1];
        session1.seasonID = [NSNumber numberWithInt: 2016];
        session1.isSelected = YES;
        
        FBSession *session2 = [NSEntityDescription insertNewObjectForEntityForName:@"FBSession" inManagedObjectContext:context];
        session2.name = @"Squad Asel";
        session2.leagueID = [NSNumber numberWithInt: 169843];
        session2.teamID = [NSNumber numberWithInt: 3];
        session2.seasonID = [NSNumber numberWithInt: 2016];
        session2.isSelected = NO;
        
        FBSession *session3 = [NSEntityDescription insertNewObjectForEntityForName:@"FBSession" inManagedObjectContext:context];
        session3.name = @"Robot Computer";
        session3.leagueID = [NSNumber numberWithInt: 186088];
        session3.teamID = [NSNumber numberWithInt: 6];
        session3.seasonID = [NSNumber numberWithInt: 2016];
        session3.isSelected = NO;
        
        FBSession *session4 = [NSEntityDescription insertNewObjectForEntityForName:@"FBSession" inManagedObjectContext:context];
        session4.name = @"Team Asel";
        session4.leagueID = [NSNumber numberWithInt: 186088];
        session4.teamID = [NSNumber numberWithInt: 5];
        session4.seasonID = [NSNumber numberWithInt: 2016];
        session4.isSelected = NO;
        
        FBSession *session5 = [NSEntityDescription insertNewObjectForEntityForName:@"FBSession" inManagedObjectContext:context];
        session5.name = @"Lob City";
        session5.leagueID = [NSNumber numberWithInt: 186088];
        session5.teamID = [NSNumber numberWithInt: 2];
        session5.seasonID = [NSNumber numberWithInt: 2016];
        session5.isSelected = NO;
        [result addObjectsFromArray:@[session1, session2, session3, session4, session5]];
    }
    
    //OLD SCORINGPERIODID METHOD
    FBSession *session = result[0];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/clubhouse?leagueId=%@&teamId=%@&seasonId=%@",session.leagueID,session.teamID,session.seasonID]];
    NSError *errorHTML;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&errorHTML];
    if (errorHTML) NSLog(@"%@",errorHTML);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//script";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    for (TFHppleElement *node in nodes) {
        if ([node.content containsString:@"scoringPeriodId"]) {
            NSString *content = node.content;
            NSRange r = [content rangeOfString:@"scoringPeriodId: "];
            int beg = (int)r.length + (int)r.location;
            int end = (int)[content rangeOfString:@",\n\t\tcurrentScoringPeriodId:"].location;
            for (FBSession *sesh in result)
                sesh.scoringPeriodID = [NSNumber numberWithInt:[[content substringWithRange:NSMakeRange(beg, end-beg)] intValue]];
            break;
        }
    }
    if (result[0].scoringPeriodID == 0) NSLog(@"scoringPeriodID is 0, likely unintended");
    
    /* //POSSIBLE NEW METHOD
     NSString *dateString = @"03-Sep-14";
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     dateFormatter.dateFormat = @"dd-MMM-yy";
     NSDate *refDate = [dateFormatter dateFromString:dateString];
     session.scoringPeriodID = (int)[self daysBetweenDate:refDate andDate:[NSDate date]];
     */
    
    //WatchList creation
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"FBWatchList" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest2 setEntity:entity2];
    NSMutableArray <FBWatchList *> *result2 = [[NSMutableArray alloc] initWithArray:
                                            [self.managedObjectContext executeFetchRequest:fetchRequest2 error:&error]];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else if (result2.count == 0) {
        NSLog(@"No watch list, creating empty list");
        NSManagedObjectContext *context = [self managedObjectContext];
        FBWatchList *wl = [NSEntityDescription insertNewObjectForEntityForName:@"FBWatchList" inManagedObjectContext:context];
        wl.playerArray = [[NSMutableArray alloc] initWithArray:@[@"LeBron James", @"Kevin Durant", @"Hassan Whiteside"]];
    }
    else if (result2.count > 1) {
        NSLog(@"Too many watch lists.");
    }
    
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"failed to save in AppDelegate: %@", [error localizedDescription]);
    }
    
    //RESideMenu init
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:
                        [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mu"]];
    navController.navigationBar.barTintColor = [UIColor FBDarkOrangeColor];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    navController.navigationBar.translucent = NO;
    navController.navigationBar.barStyle = UIBarStyleBlack;
    [navController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController: navController
                                                                    leftMenuViewController:[[LeftSideMenuViewController alloc] init]
                                                                   rightMenuViewController:nil];
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"StadiumBlur2.jpg"];
    sideMenuViewController.scaleBackgroundImageView = YES;
    sideMenuViewController.scaleContentView = YES;
    sideMenuViewController.scaleMenuView = YES;
    sideMenuViewController.contentViewScaleValue = 0.8;
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    self.window.rootViewController = sideMenuViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setTintColor:[UIColor FBDarkOrangeColor]];
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

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iDocs.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

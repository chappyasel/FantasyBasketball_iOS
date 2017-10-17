//
//  FBSession+CoreDataProperties.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/1/15.
//  Copyright © 2015 CD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FBSession+CoreDataProperties.h"
#import "AppDelegate.h"

@implementation FBSession (CoreDataProperties)

@dynamic isSelected;

@dynamic name;

@dynamic leagueID;
@dynamic teamID;
@dynamic seasonID;

@dynamic scoringPeriodID;

+ (FBSession *)fetchCurrentSession {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FBSession" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) NSLog(@"%@",error);
    if (fetchedObjects.count == 0 || fetchedObjects.count > 1) NSLog(@"FETCHED OBJECTS ERROR IN FBSESSION CLASS");
    return fetchedObjects[0];
}

@end

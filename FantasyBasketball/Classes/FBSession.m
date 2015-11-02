//
//  FBSession.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/1/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBSession.h"
#import "AppDelegate.h"

@implementation FBSession

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
    if (fetchedObjects.count == 0 || fetchedObjects.count > 1) NSLog(@"FETCHED OBJECTS ERROR");
    return fetchedObjects[0];
}

@end

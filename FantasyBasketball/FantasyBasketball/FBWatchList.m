//
//  FBWatchList.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/28/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBWatchList.h"
#import "AppDelegate.h"

@implementation FBWatchList

+ (FBWatchList *)fetchWatchList {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FBWatchList" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"];
    //[fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) NSLog(@"%@",error);
    if (fetchedObjects.count == 0 || fetchedObjects.count > 1) NSLog(@"FETCHED OBJECTS ERROR IN FBWATCHLIST CLASS");
    return fetchedObjects[0];
}

- (void)setPlayerArray:(NSMutableArray *)playerArray {
    self.players = [NSKeyedArchiver archivedDataWithRootObject:playerArray];
}

- (void)addPlayerArrayObject:(id)object {
    self.playerArray[self.playerArray.count] = object;
    self.players = [NSKeyedArchiver archivedDataWithRootObject:self.playerArray];
}

-(NSMutableArray *)playerArray {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.players];
}

@end

//
//  FBNewsSettings.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/29/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBNewsSettings.h"
#import "AppDelegate.h"

@implementation FBNewsSettings

+ (FBNewsSettings *)fetchNewsSettings {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FBNewsSettings" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"];
    //[fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) NSLog(@"%@",error);
    if (fetchedObjects.count == 0 || fetchedObjects.count > 1) NSLog(@"FETCHED OBJECTS ERROR IN FBNEWSSETTINGS CLASS");
    return fetchedObjects[0];
}

- (void)setSelectorDataArray:(NSMutableArray<NSNumber *> *)selectorDataArray {
    self.selectorData = [NSKeyedArchiver archivedDataWithRootObject:selectorDataArray];
}

- (NSMutableArray<NSNumber *> *)selectorDataArray {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.selectorData];
}

@end

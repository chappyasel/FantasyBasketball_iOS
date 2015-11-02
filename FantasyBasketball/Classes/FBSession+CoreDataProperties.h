//
//  FBSession+CoreDataProperties.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/1/15.
//  Copyright © 2015 CD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FBSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBSession (CoreDataProperties)

@property bool isSelected;
@property (nullable, nonatomic, retain) NSNumber *priority;

@property (nullable, nonatomic, retain) NSNumber *leagueID;
@property (nullable, nonatomic, retain) NSNumber *teamID;
@property (nullable, nonatomic, retain) NSNumber *seasonID;

@property (nullable, nonatomic, retain) NSNumber *scoringPeriodID;

@end

NS_ASSUME_NONNULL_END

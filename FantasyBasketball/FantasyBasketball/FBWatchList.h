//
//  FBWatchList.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/28/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBWatchList : NSManagedObject

@property (nonatomic) NSMutableArray *playerArray;

+ (FBWatchList *)fetchWatchList;

@end

NS_ASSUME_NONNULL_END

#import "FBWatchList+CoreDataProperties.h"

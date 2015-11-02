//
//  FBSession.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/1/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBSession : NSManagedObject

+ (FBSession *)fetchCurrentSession;

@end

NS_ASSUME_NONNULL_END

#import "FBSession+CoreDataProperties.h"

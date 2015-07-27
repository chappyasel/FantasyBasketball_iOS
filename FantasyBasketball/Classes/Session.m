//
//  Session.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "Session.h"

@implementation Session

+ (Session *)sharedInstance {
    static Session *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Session alloc] init];
    });
    return _sharedInstance;
}

@end

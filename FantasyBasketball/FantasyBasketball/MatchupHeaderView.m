//
//  MatchupHeaderView.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 10/19/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "MatchupHeaderView.h"

@implementation MatchupHeaderView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor FBMediumOrangeColor];
        self.autorefreshSwitch.onTintColor = [UIColor whiteColor];
        self.autorefreshSwitch.tintColor = [UIColor whiteColor];
        self.expandStatsSwitch.onTintColor = [UIColor whiteColor];
        self.expandStatsSwitch.tintColor = [UIColor whiteColor];
    }
    return self;
}

@end

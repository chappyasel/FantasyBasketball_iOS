//
//  ScoreboardCell.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/28/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScoreboardCellDelegate <NSObject>

- (void)linkWithMatchupLink: (NSString *)link;

@end

@interface ScoreboardCell : UITableViewCell

@property (nonatomic, weak) id <ScoreboardCellDelegate> delegate;

@property NSDictionary *matchup;

- (instancetype) initWithMatchup: (NSDictionary *)matchup view:(UIViewController *)superview size:(CGSize)size;

- (void)updateWithMatchup: (NSDictionary *) matchup;

@end

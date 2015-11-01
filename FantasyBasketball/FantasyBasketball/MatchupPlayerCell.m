//
//  MatchupPlayerCell.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/28/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MatchupPlayerCell.h"

@implementation MatchupPlayerCell {
    UILabel *rightSubnameView;
    UILabel *leftSubnameView;
    UILabel *rightSubname2View;
    UILabel *leftSubname2View;
    UILabel *rightPointsView;
    UILabel *leftPointsView;
}

- (instancetype) initWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP view:(UIViewController *)superview expanded:(bool)expanded {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self = [super initWithFrame:CGRectMake(0, 0, 414, 152.7)]) {
        self.rightPlayer = rP;
        self.leftPlayer = lP;
        if (self.leftPlayer) {
            //NAME
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 25)];
            name.text = [NSString stringWithFormat:@"%@. %@",[self.leftPlayer.firstName substringToIndex:1],self.leftPlayer.lastName];
            [self addSubview:name];
            //INFO
            leftSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(10, 19, 150, 20)];
            leftSubnameView.textColor = [UIColor grayColor];
            leftSubnameView.font = [leftSubnameView.font fontWithSize:11];
            if (self.leftPlayer.isPlaying) leftSubnameView.text = [NSString stringWithFormat:@"%@, %@ %@",self.leftPlayer.opponent,self.leftPlayer.status,self.leftPlayer.score];
            else leftSubnameView.text = @"-";
            [self addSubview:leftSubnameView];
            if (self.leftPlayer.gameState != FBGameStateHasntStarted) {
                //STATS
                leftSubname2View = [[UILabel alloc] initWithFrame:CGRectMake(10, 32, 150, 20)];
                leftSubname2View.textColor = [UIColor grayColor];
                leftSubname2View.font = [leftSubname2View.font fontWithSize:11];
                int stat1 = 0;
                int stat2 = 0;
                NSString *stat1t = @"";
                NSString *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
                if ((int)self.leftPlayer.blocks >= (int)self.leftPlayer.assists ||
                    (int)self.leftPlayer.steals > (int)self.leftPlayer.assists ||
                    (int)self.leftPlayer.steals > (int)self.leftPlayer.rebounds) {
                    if ((int)self.leftPlayer.rebounds >= (int)self.leftPlayer.assists) {
                        stat1 = self.leftPlayer.rebounds;
                        stat1t = @"reb";
                    }
                    else {
                        stat1 = self.leftPlayer.assists;
                        stat1t = @"ast";
                    }
                    if ((int)self.leftPlayer.blocks >= (int)self.leftPlayer.steals) {
                        stat2 = self.leftPlayer.blocks;
                        stat2t = @"blk";
                    }
                    else {
                        stat2 = self.leftPlayer.steals;
                        stat2t = @"stl";
                    }
                }
                else {
                    stat1 = self.leftPlayer.rebounds;
                    stat1t = @"reb";
                    stat2 = self.rightPlayer.assists;
                    stat2t = @"ast";
                }
                leftSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f pts, %d %@, %d %@",self.leftPlayer.fgm,self.leftPlayer.fga,self.leftPlayer.points,stat1,stat1t,stat2,stat2t];
                [self addSubview:leftSubname2View];
            }
            //Points
            leftPointsView = [[UILabel alloc] initWithFrame:CGRectMake(207-50, 0, 50, 52.7)];
            if (!self.leftPlayer.isPlaying) leftPointsView.text = @"-";
            else leftPointsView.text = [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints];
            if (self.leftPlayer.gameState == FBGameStateHasntStarted) leftPointsView.textColor = [UIColor lightGrayColor];
            else leftPointsView.textColor = [UIColor blackColor];
            leftPointsView.textAlignment = NSTextAlignmentCenter;
            leftPointsView.font = [UIFont boldSystemFontOfSize:19];
            [self addSubview:leftPointsView];
            //Link
            UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 207-50, 52.7)];
            [link addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
            link.tag = 0;
            link.backgroundColor = [UIColor clearColor];
            link.titleLabel.text = @"";
            [self addSubview:link];
            //Game link
            UIButton *gLink = [[UIButton alloc] initWithFrame:CGRectMake(207-50, 0, 50, 52.7)];
            if (self.leftPlayer.isPlaying) [gLink addTarget:self action:@selector(linkGameLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
            gLink.tag = 0;
            gLink.backgroundColor = [UIColor clearColor];
            gLink.titleLabel.text = @"";
            [self addSubview:gLink];
            if (expanded) {
                
            }
        }
        if (self.rightPlayer) {
            //NAME
            UILabel *name2 = [[UILabel alloc] initWithFrame:CGRectMake(414-160, 0, 150, 25)];
            name2.text = [NSString stringWithFormat:@"%@. %@",[self.rightPlayer.firstName substringToIndex:1],self.rightPlayer.lastName];
            name2.textAlignment = NSTextAlignmentRight;
            [self addSubview:name2];
            //INFO
            rightSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(414-160, 20, 150, 20)];
            rightSubnameView.font = [rightSubnameView.font fontWithSize:11];
            rightSubnameView.textColor = [UIColor grayColor];
            rightSubnameView.textAlignment = NSTextAlignmentRight;
            if (self.rightPlayer.isPlaying) rightSubnameView.text = [NSString stringWithFormat:@"%@ %@, %@",self.rightPlayer.status,self.rightPlayer.score,self.rightPlayer.opponent];
            else rightSubnameView.text = @"-";
            [self addSubview:rightSubnameView];
            if (self.rightPlayer.gameState != FBGameStateHasntStarted) {
                //STATS
                rightSubname2View = [[UILabel alloc] initWithFrame:CGRectMake(414-160, 32, 150, 20)];
                rightSubname2View.textColor = [UIColor grayColor];
                rightSubname2View.font = [rightSubname2View.font fontWithSize:11];
                rightSubname2View.textAlignment = NSTextAlignmentRight;
                int stat1 = 0;
                int stat2 = 0;
                NSString *stat1t = @"";
                NSString *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
                if ((int)self.rightPlayer.blocks >= (int)self.rightPlayer.assists ||
                    (int)self.rightPlayer.steals > (int)self.rightPlayer.assists ||
                    (int)self.rightPlayer.steals > (int)self.rightPlayer.rebounds) {
                    if ((int)self.rightPlayer.rebounds >= (int)self.rightPlayer.assists) {
                        stat1 = self.rightPlayer.rebounds;
                        stat1t = @"reb";
                    }
                    else {
                        stat1 = self.rightPlayer.assists;
                        stat1t = @"ast";
                    }
                    if ((int)self.rightPlayer.blocks >= (int)self.rightPlayer.steals) {
                        stat2 = self.rightPlayer.blocks;
                        stat2t = @"blk";
                    }
                    else {
                        stat2 = self.rightPlayer.steals;
                        stat2t = @"stl";
                    }
                }
                else {
                    stat1 = self.rightPlayer.rebounds;
                    stat1t = @"reb";
                    stat2 = self.rightPlayer.assists;
                    stat2t = @"ast";
                }
                rightSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f pts, %d %@, %d %@",self.rightPlayer.fgm,self.rightPlayer.fga,self.rightPlayer.points,stat1,stat1t,stat2,stat2t];
                [self addSubview:rightSubname2View];
            }
            //Points
            rightPointsView = [[UILabel alloc] initWithFrame:CGRectMake(207, 0, 50, 52.7)];
            if (!self.rightPlayer.isPlaying || self.rightPlayer.gameState == FBGameStateHasntStarted) rightPointsView.text = @"-";
            else rightPointsView.text = [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints];
            if (self.rightPlayer.gameState == FBGameStateHasntStarted) rightPointsView.textColor = [UIColor lightGrayColor];
            else rightPointsView.textColor = [UIColor blackColor];
            rightPointsView.textAlignment = NSTextAlignmentCenter;
            rightPointsView.font = [UIFont boldSystemFontOfSize:19];
            [self addSubview:rightPointsView];
            //Link
            UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(208+50, 0, 207-50, 52.7)];
            [link addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
            link.tag = 1;
            link.backgroundColor = [UIColor clearColor];
            link.titleLabel.text = @"";
            [self addSubview:link];
            //Game link
            UIButton *gLink = [[UIButton alloc] initWithFrame:CGRectMake(208, 0, 50, 52.7)];
            if (self.rightPlayer.isPlaying) [gLink addTarget:self action:@selector(linkGameLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
            gLink.tag = 1;
            gLink.backgroundColor = [UIColor clearColor];
            gLink.titleLabel.text = @"";
            [self addSubview:gLink];
            if (expanded) {
                
            }
        }
    }
    return self;
}

- (void)updateWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP {
    self.rightPlayer = rP;
    self.leftPlayer = lP;
    if (self.rightPlayer.isPlaying) rightSubnameView.text = [NSString stringWithFormat:@"%@ %@, %@",self.rightPlayer.status,self.rightPlayer.score,self.rightPlayer.opponent];
    else rightSubnameView.text = @"-";
    if (self.leftPlayer.isPlaying) leftSubnameView.text = [NSString stringWithFormat:@"%@, %@ %@",self.leftPlayer.opponent,self.leftPlayer.status,self.leftPlayer.score];
    else leftSubnameView.text = @"-";
    if (self.rightPlayer.gameState != FBGameStateHasntStarted) {
        int stat1 = 0;
        int stat2 = 0;
        NSString *stat1t = @"";
        NSString *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
        if ((int)self.rightPlayer.blocks >= (int)self.rightPlayer.assists ||
            (int)self.rightPlayer.steals > (int)self.rightPlayer.assists ||
            (int)self.rightPlayer.steals > (int)self.rightPlayer.rebounds) {
            if ((int)self.rightPlayer.rebounds >= (int)self.rightPlayer.assists) {
                stat1 = self.rightPlayer.rebounds;
                stat1t = @"reb";
            }
            else {
                stat1 = self.rightPlayer.assists;
                stat1t = @"ast";
            }
            if ((int)self.rightPlayer.blocks >= (int)self.rightPlayer.steals) {
                stat2 = self.rightPlayer.blocks;
                stat2t = @"blk";
            }
            else {
                stat2 = self.rightPlayer.steals;
                stat2t = @"stl";
            }
        }
        else {
            stat1 = self.rightPlayer.rebounds;
            stat1t = @"reb";
            stat2 = self.rightPlayer.assists;
            stat2t = @"ast";
        }
        rightSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f pts, %d %@, %d %@",self.rightPlayer.fgm,self.rightPlayer.fga,self.rightPlayer.points,stat1,stat1t,stat2,stat2t];
    }
    if (self.leftPlayer.gameState != FBGameStateHasntStarted) {
        int stat1 = 0;
        int stat2 = 0;
        NSString *stat1t = @"";
        NSString *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
        if ((int)self.leftPlayer.blocks >= (int)self.leftPlayer.assists ||
            (int)self.leftPlayer.steals > (int)self.leftPlayer.assists ||
            (int)self.leftPlayer.steals > (int)self.leftPlayer.rebounds) {
            if ((int)self.leftPlayer.rebounds >= (int)self.leftPlayer.assists) {
                stat1 = self.leftPlayer.rebounds;
                stat1t = @"reb";
            }
            else {
                stat1 = self.leftPlayer.assists;
                stat1t = @"ast";
            }
            if ((int)self.leftPlayer.blocks >= (int)self.leftPlayer.steals) {
                stat2 = self.leftPlayer.blocks;
                stat2t = @"blk";
            }
            else {
                stat2 = self.leftPlayer.steals;
                stat2t = @"stl";
            }
        }
        else {
            stat1 = self.leftPlayer.rebounds;
            stat1t = @"reb";
            stat2 = self.rightPlayer.assists;
            stat2t = @"ast";
        }
        leftSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f pts, %d %@, %d %@",self.leftPlayer.fgm,self.leftPlayer.fga,self.leftPlayer.points,stat1,stat1t,stat2,stat2t];
    }
    if (!self.rightPlayer.isPlaying) rightPointsView.text = @"-";
    else if (![rightPointsView.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints]]) {
        rightPointsView.text = [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints];
        [self highlightRightScore];
    }
    if (!self.leftPlayer.isPlaying) leftPointsView.text = @"-";
    else if (![leftPointsView.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints]]) {
        leftPointsView.text = [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints];
        [self highlightLeftScore];
    }
    if (self.rightPlayer.gameState == FBGameStateHasntStarted) rightPointsView.textColor = [UIColor lightGrayColor];
    else rightPointsView.textColor = [UIColor blackColor];
    if (self.leftPlayer.gameState == FBGameStateHasntStarted) leftPointsView.textColor = [UIColor lightGrayColor];
    else leftPointsView.textColor = [UIColor blackColor];
}

- (void)highlightLeftScore {
    leftPointsView.backgroundColor = [UIColor colorWithRed:0/255.0 green:150/255.0 blue:255/255.0 alpha:1];
    [self performSelector:@selector(unhighlightLeftScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightLeftScore { leftPointsView.backgroundColor = [UIColor whiteColor]; };

- (void)highlightRightScore {
    rightPointsView.backgroundColor = [UIColor colorWithRed:0/255.0 green:150/255.0 blue:255/255.0 alpha:1];
    [self performSelector:@selector(unhighlightRightScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightRightScore { rightPointsView.backgroundColor = [UIColor whiteColor]; };

- (void)linkGameLinkPressed:(UIButton *)sender {
    if (sender.tag == 0) [self.delegate linkWithGameLink:self.leftPlayer];
    if (sender.tag == 1) [self.delegate linkWithGameLink:self.rightPlayer];
}

- (void)linkPlayerPressed:(UIButton *)sender {
    if (sender.tag == 0) [self.delegate linkWithPlayer:self.leftPlayer];
    if (sender.tag == 1) [self.delegate linkWithPlayer:self.rightPlayer];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

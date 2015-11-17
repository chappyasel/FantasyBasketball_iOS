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
    UIView *rightPointsBackground;
    UILabel *leftPointsView;
    UIView *leftPointsBackground;
}

- (instancetype) initWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP view:(UIViewController *)superview expanded:(bool)expanded size:(CGSize)size{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        self.rightPlayer = rP;
        self.leftPlayer = lP;
        if (self.leftPlayer) {
            //NAME
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, size.width/2-50-5, 25)];
            name.text = [NSString stringWithFormat:@"%@. %@",[self.leftPlayer.firstName substringToIndex:1],self.leftPlayer.lastName];
            [self addSubview:name];
            //INFO
            leftSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(10, 19, size.width/2-50-5, 20)];
            leftSubnameView.textColor = [UIColor grayColor];
            leftSubnameView.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
            if (self.leftPlayer.isPlaying) leftSubnameView.text = [NSString stringWithFormat:@"%@, %@ %@",self.leftPlayer.opponent,self.leftPlayer.status,self.leftPlayer.score];
            else leftSubnameView.text = @"-";
            [self addSubview:leftSubnameView];
            //INJURY
            if (![self.leftPlayer.injury isEqualToString:@""]) {
                UILabel *injury = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2-50, 0, 50, 15)];
                injury.font = [UIFont boldSystemFontOfSize:9];
                injury.textColor = [UIColor redColor];
                injury.textAlignment = NSTextAlignmentCenter;
                injury.text = self.leftPlayer.injury;
                [self addSubview:injury];
            }
            if (self.leftPlayer.gameState != FBGameStateHasntStarted) {
                //STATS
                leftSubname2View = [[UILabel alloc] initWithFrame:CGRectMake(10, 32, size.width/2-50-10, 20)];
                leftSubname2View.textColor = [UIColor grayColor];
                leftSubname2View.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
                NSArray *strList = @[@"pts",@"r",@"a",@"s",@"b"];
                if (size.width > 400) strList = @[@"pts",@"reb",@"ast",@"stl",@"blk"];
                int stat1 = 0;
                int stat2 = 0;
                NSString *stat1t = @"";
                NSString *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
                if ((int)self.leftPlayer.blocks >= (int)self.leftPlayer.assists ||
                    (int)self.leftPlayer.steals > (int)self.leftPlayer.assists ||
                    (int)self.leftPlayer.steals > (int)self.leftPlayer.rebounds) {
                    if ((int)self.leftPlayer.rebounds >= (int)self.leftPlayer.assists) {
                        stat1 = self.leftPlayer.rebounds;
                        stat1t = strList[1];
                    }
                    else {
                        stat1 = self.leftPlayer.assists;
                        stat1t = strList[2];
                    }
                    if ((int)self.leftPlayer.blocks >= (int)self.leftPlayer.steals) {
                        stat2 = self.leftPlayer.blocks;
                        stat2t = strList[4];
                    }
                    else {
                        stat2 = self.leftPlayer.steals;
                        stat2t = strList[3];
                    }
                }
                else {
                    stat1 = self.leftPlayer.rebounds;
                    stat1t = strList[1];
                    stat2 = self.leftPlayer.assists;
                    stat2t = strList[2];
                }
                leftSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f %@, %d %@, %d %@",self.leftPlayer.fgm,self.leftPlayer.fga,self.leftPlayer.points,strList[0],stat1,stat1t,stat2,stat2t];
                [self addSubview:leftSubname2View];
            }
            //Points
            leftPointsView = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2-50, 0, 50, size.height)];
            leftPointsBackground = [[UIView alloc] initWithFrame:leftPointsView.frame];
            leftPointsBackground.backgroundColor = [UIColor blackColor];
            leftPointsBackground.alpha = 0.0;
            if (!self.leftPlayer.isPlaying) leftPointsView.text = @"-";
            else leftPointsView.text = [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints];
            if (self.leftPlayer.gameState == FBGameStateHasntStarted) leftPointsView.textColor = [UIColor lightGrayColor];
            else leftPointsView.textColor = [UIColor blackColor];
            leftPointsView.textAlignment = NSTextAlignmentCenter;
            leftPointsView.font = [UIFont boldSystemFontOfSize:19];
            [self addSubview:leftPointsBackground];
            [self addSubview:leftPointsView];
            //Link
            UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width/2-50, size.height)];
            [link addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
            link.tag = 0;
            link.backgroundColor = [UIColor clearColor];
            link.titleLabel.text = @"";
            [self addSubview:link];
            //Game link
            UIButton *gLink = [[UIButton alloc] initWithFrame:CGRectMake(size.width/2-50, 0, 50, size.height)];
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
            UILabel *name2 = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2+50, 0, size.width/2-50-10, 25)];
            name2.text = [NSString stringWithFormat:@"%@. %@",[self.rightPlayer.firstName substringToIndex:1],self.rightPlayer.lastName];
            name2.textAlignment = NSTextAlignmentRight;
            [self addSubview:name2];
            //INFO
            rightSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2+50, 20, size.width/2-50-10, 20)];
            rightSubnameView.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
            rightSubnameView.textColor = [UIColor grayColor];
            rightSubnameView.textAlignment = NSTextAlignmentRight;
            if (self.rightPlayer.isPlaying) rightSubnameView.text = [NSString stringWithFormat:@"%@ %@, %@",self.rightPlayer.status,self.rightPlayer.score,self.rightPlayer.opponent];
            else rightSubnameView.text = @"-";
            [self addSubview:rightSubnameView];
            if (self.rightPlayer.gameState != FBGameStateHasntStarted) {
                //STATS
                rightSubname2View = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2+50, 32, size.width/2-50-10, 20)];
                rightSubname2View.textColor = [UIColor grayColor];
                rightSubname2View.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
                rightSubname2View.textAlignment = NSTextAlignmentRight;
                NSArray *strList = @[@"pts",@"r",@"a",@"s",@"b"];
                if (size.width > 400) strList = @[@"pts",@"reb",@"ast",@"stl",@"blk"];
                int stat1 = 0;
                int stat2 = 0;
                NSString *stat1t = @"";
                NSString *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
                if ((int)self.rightPlayer.blocks > (int)self.rightPlayer.assists ||
                    (int)self.rightPlayer.steals > (int)self.rightPlayer.assists ||
                    (int)self.rightPlayer.steals > (int)self.rightPlayer.rebounds) {
                    if ((int)self.rightPlayer.rebounds >= (int)self.rightPlayer.assists) {
                        stat1 = self.rightPlayer.rebounds;
                        stat1t = strList[1];
                    }
                    else {
                        stat1 = self.rightPlayer.assists;
                        stat1t = strList[2];
                    }
                    if ((int)self.rightPlayer.blocks >= (int)self.rightPlayer.steals) {
                        stat2 = self.rightPlayer.blocks;
                        stat2t = strList[4];
                    }
                    else {
                        stat2 = self.rightPlayer.steals;
                        stat2t = strList[3];
                    }
                }
                else {
                    stat1 = self.rightPlayer.rebounds;
                    stat1t = strList[1];
                    stat2 = self.rightPlayer.assists;
                    stat2t = strList[2];
                }
                rightSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f %@, %d %@, %d %@",self.rightPlayer.fgm,self.rightPlayer.fga,self.rightPlayer.points,strList[0],stat1,stat1t,stat2,stat2t];
                [self addSubview:rightSubname2View];
            }
            //Points
            rightPointsView = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2, 0, 50, size.height)];
            rightPointsBackground = [[UIView alloc] initWithFrame:rightPointsView.frame];
            rightPointsBackground.backgroundColor = [UIColor blackColor];
            rightPointsBackground.alpha = 0.0;
            if (!self.rightPlayer.isPlaying) rightPointsView.text = @"-";
            else rightPointsView.text = [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints];
            if (self.rightPlayer.gameState == FBGameStateHasntStarted) rightPointsView.textColor = [UIColor lightGrayColor];
            else rightPointsView.textColor = [UIColor blackColor];
            rightPointsView.textAlignment = NSTextAlignmentCenter;
            rightPointsView.font = [UIFont boldSystemFontOfSize:19];
            [self addSubview:rightPointsBackground];
            [self addSubview:rightPointsView];
            //Link
            UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(size.width/2+50, 0, size.width/2-50, size.height)];
            [link addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
            link.tag = 1;
            link.backgroundColor = [UIColor clearColor];
            link.titleLabel.text = @"";
            [self addSubview:link];
            //Game link
            UIButton *gLink = [[UIButton alloc] initWithFrame:CGRectMake(size.width/2, 0, 50, size.height)];
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
            stat2 = self.leftPlayer.assists;
            stat2t = @"ast";
        }
        leftSubname2View.text = [NSString stringWithFormat:@"%.0f/%.0f, %.0f pts, %d %@, %d %@",self.leftPlayer.fgm,self.leftPlayer.fga,self.leftPlayer.points,stat1,stat1t,stat2,stat2t];
    }
    if (!self.rightPlayer.isPlaying) rightPointsView.text = @"-";
    else if (![rightPointsView.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints]]) {
        if (rightPointsView.text.intValue <= (int)self.rightPlayer.fantasyPoints) rightPointsBackground.backgroundColor = [UIColor FBBlueHighlightColor];
        else rightPointsBackground.backgroundColor = [UIColor FBRedHighlightColor];
        rightPointsView.text = [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints];
        [self highlightRightScore];
    }
    if (!self.leftPlayer.isPlaying) leftPointsView.text = @"-";
    else if (![leftPointsView.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints]]) {
        if (leftPointsView.text.intValue <= (int)self.leftPlayer.fantasyPoints) leftPointsBackground.backgroundColor = [UIColor FBBlueHighlightColor];
        else leftPointsBackground.backgroundColor = [UIColor FBRedHighlightColor];
        leftPointsView.text = [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints];
        [self highlightLeftScore];
    }
    if (self.rightPlayer.gameState == FBGameStateHasntStarted) rightPointsView.textColor = [UIColor lightGrayColor];
    else rightPointsView.textColor = [UIColor blackColor];
    if (self.leftPlayer.gameState == FBGameStateHasntStarted) leftPointsView.textColor = [UIColor lightGrayColor];
    else leftPointsView.textColor = [UIColor blackColor];
}

- (void)highlightLeftScore {
    leftPointsBackground.alpha = 1.0;
    [self performSelector:@selector(unhighlightLeftScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightLeftScore {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:3.5 animations:^{
        leftPointsBackground.alpha = 0.0;
    }];
};

- (void)highlightRightScore {
    rightPointsBackground.alpha = 1.0;
    [self performSelector:@selector(unhighlightRightScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightRightScore {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:3.5 animations:^{
        rightPointsBackground.alpha = 0.0;
    }];
};

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

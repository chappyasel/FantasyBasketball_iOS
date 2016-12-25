//
//  MatchupPlayerCell.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/28/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MatchupPlayerCell.h"

@interface MatchupPlayerCell()

@property UILabel *rightSubnameView;
@property UILabel *leftSubnameView;

@property UILabel *rightSubname2View;
@property UILabel *leftSubname2View;

@property UILabel *rightPointsView;
@property UIView *rightPointsBackground;
@property UILabel *leftPointsView;
@property UIView *leftPointsBackground;

@property NSMutableArray <UILabel *> *leftScores;
@property NSMutableArray <UILabel *> *rightScores;

@property CGSize size;
@property BOOL expanded;

@end

@implementation MatchupPlayerCell

- (instancetype) initWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP view:(UIViewController *)superview expanded:(bool)expanded size:(CGSize)size{
    self.size = size;
    self.expanded = expanded;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        self.rightPlayer = rP;
        self.leftPlayer = lP;
        if (self.leftPlayer) {
            //NAME
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, size.width/2-50-5, 25)];
            name.text = [NSString stringWithFormat:@"%@. %@",[self.leftPlayer.firstName substringToIndex:1],self.leftPlayer.lastName];
            [self addSubview:name];
            //POINTS
            self.leftPointsView = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2-50, 0, 50, size.height)];
            self.leftPointsBackground = [[UIView alloc] initWithFrame:self.leftPointsView.frame];
            self.leftPointsBackground.backgroundColor = [UIColor blackColor];
            self.leftPointsBackground.alpha = 0.0;
            if (!self.leftPlayer.isPlaying) self.leftPointsView.text = @"-";
            else self.leftPointsView.text = [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints];
            if (self.leftPlayer.gameState == FBGameStateHasntStarted) self.leftPointsView.textColor = [UIColor lightGrayColor];
            else self.leftPointsView.textColor = [UIColor blackColor];
            self.leftPointsView.textAlignment = NSTextAlignmentCenter;
            self.leftPointsView.font = [UIFont boldSystemFontOfSize:19];
            [self addSubview:self.leftPointsBackground];
            [self addSubview:self.leftPointsView];
            //INJURY
            if (![self.leftPlayer.injury isEqualToString:@""]) {
                UILabel *injury = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2-50, 0, 50, 18)];
                if (!self.expanded) injury.frame = CGRectMake(size.width/2-50, 0, 50, 14);
                injury.font = [UIFont boldSystemFontOfSize:9];
                injury.textColor = [UIColor redColor];
                injury.textAlignment = NSTextAlignmentCenter;
                injury.text = self.leftPlayer.injury;
                [self addSubview:injury];
            }
            //INFO
            self.leftSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(10, 19, size.width/2-50-5, 20)];
            self.leftSubnameView.textColor = [UIColor grayColor];
            self.leftSubnameView.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
            NSString *leftPlayerStats = [self statsForPlayer:self.leftPlayer expanded:(size.width > 400 && self.expanded)];
            if (self.leftPlayer.isPlaying)
                self.leftSubnameView.text = (self.expanded) ?
                    [NSString stringWithFormat:@"%@, %@ %@",self.leftPlayer.opponent,self.leftPlayer.status,self.leftPlayer.score] :
                    [NSString stringWithFormat:@"%@: %@",self.leftPlayer.status, leftPlayerStats];
            else self.leftSubnameView.text = @"-";
            [self addSubview:self.leftSubnameView];
            if (self.expanded) {
                self.leftSubname2View = [[UILabel alloc] initWithFrame:CGRectMake(10, 32, size.width/2-50-10, 20)];
                self.leftSubname2View.textColor = [UIColor clearColor];
                self.leftSubname2View.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
                if (self.leftPlayer.gameState != FBGameStateHasntStarted) {
                    //STATS
                    self.leftSubname2View.textColor = [UIColor grayColor];
                    self.leftSubname2View.text = leftPlayerStats;
                    [self addSubview:self.leftSubname2View];
                }
            }
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
        }
        if (self.rightPlayer) {
            //NAME
            UILabel *name2 = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2+50, 0, size.width/2-50-10, 25)];
            name2.text = [NSString stringWithFormat:@"%@. %@",[self.rightPlayer.firstName substringToIndex:1],self.rightPlayer.lastName];
            name2.textAlignment = NSTextAlignmentRight;
            [self addSubview:name2];
            //POINTS
            self.rightPointsView = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2, 0, 50, size.height)];
            self.rightPointsBackground = [[UIView alloc] initWithFrame:self.rightPointsView.frame];
            self.rightPointsBackground.backgroundColor = [UIColor blackColor];
            self.rightPointsBackground.alpha = 0.0;
            if (!self.rightPlayer.isPlaying) self.rightPointsView.text = @"-";
            else self.rightPointsView.text = [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints];
            if (self.rightPlayer.gameState == FBGameStateHasntStarted) self.rightPointsView.textColor = [UIColor lightGrayColor];
            else self.rightPointsView.textColor = [UIColor blackColor];
            self.rightPointsView.textAlignment = NSTextAlignmentCenter;
            self.rightPointsView.font = [UIFont boldSystemFontOfSize:19];
            [self addSubview:self.rightPointsBackground];
            [self addSubview:self.rightPointsView];
            //INJURY
            if (![self.rightPlayer.injury isEqualToString:@""]) {
                UILabel *injury = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2, 0, 50, 18)];
                if (!self.expanded) injury.frame = CGRectMake(size.width/2, 0, 50, 14);
                injury.font = [UIFont boldSystemFontOfSize:9];
                injury.textColor = [UIColor redColor];
                injury.textAlignment = NSTextAlignmentCenter;
                injury.text = self.rightPlayer.injury;
                [self addSubview:injury];
            }
            //INFO
            self.rightSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2+50, 20, size.width/2-50-10, 20)];
            self.rightSubnameView.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
            self.rightSubnameView.textColor = [UIColor grayColor];
            self.rightSubnameView.textAlignment = NSTextAlignmentRight;
            NSString *rightPlayerStats = [self statsForPlayer:self.rightPlayer expanded:(size.width > 400 && self.expanded)];
            if (self.rightPlayer.isPlaying)
                self.rightSubnameView.text = (self.expanded) ?
                [NSString stringWithFormat:@"%@ %@, %@",self.rightPlayer.status,self.rightPlayer.score,self.rightPlayer.opponent] :
                [NSString stringWithFormat:@"%@: %@",rightPlayerStats,self.rightPlayer.status];
            else self.rightSubnameView.text = @"-";
            [self addSubview:self.rightSubnameView];
            if (self.expanded) {
                self.rightSubname2View = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2+50, 32, size.width/2-50-10, 20)];
                self.rightSubname2View.textColor = [UIColor clearColor];
                self.rightSubname2View.textAlignment = NSTextAlignmentRight;
                self.rightSubname2View.font = (size.width > 400) ? [UIFont systemFontOfSize:11]:[UIFont systemFontOfSize:9];
                if (self.rightPlayer.gameState != FBGameStateHasntStarted) {
                    //STATS
                    self.rightSubname2View.textColor = [UIColor grayColor];
                    self.rightSubname2View.text = [self statsForPlayer:self.rightPlayer expanded:(size.width > 400 && self.expanded)];
                    [self addSubview:self.rightSubname2View];
                }
            }
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
        }
    }
    return self;
}

- (void)updateWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP {
    self.rightPlayer = rP;
    self.leftPlayer = lP;
    NSString *rightPlayerStats = [self statsForPlayer:self.rightPlayer expanded:(self.frame.size.width > 400 && self.expanded)];
    NSString *leftPlayerStats = [self statsForPlayer:self.leftPlayer expanded:(self.frame.size.width > 400 && self.expanded)];
    if (self.rightPlayer.isPlaying)
        self.rightSubnameView.text = (self.expanded) ?
        [NSString stringWithFormat:@"%@ %@, %@",self.rightPlayer.status,self.rightPlayer.score,self.rightPlayer.opponent] :
        [NSString stringWithFormat:@"%@: %@",rightPlayerStats,self.rightPlayer.status];
    else self.rightSubnameView.text = @"-";
    if (self.leftPlayer.isPlaying)
        self.leftSubnameView.text = (self.expanded) ?
        [NSString stringWithFormat:@"%@, %@ %@",self.leftPlayer.opponent,self.leftPlayer.status,self.leftPlayer.score] :
        [NSString stringWithFormat:@"%@: %@",self.leftPlayer.status, leftPlayerStats];
    else self.leftSubnameView.text = @"-";
    if (self.expanded && self.rightPlayer.gameState != FBGameStateHasntStarted) {
        self.rightSubname2View.textColor = [UIColor grayColor];
        self.rightSubname2View.text = rightPlayerStats;
    }
    if (self.expanded && self.leftPlayer.gameState != FBGameStateHasntStarted) {
        self.leftSubname2View.textColor = [UIColor grayColor];
        self.leftSubname2View.text = leftPlayerStats;
    }
    if (!self.rightPlayer.isPlaying) self.rightPointsView.text = @"-";
    else if (![self.rightPointsView.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints]]) {
        if (self.rightPointsView.text.intValue <= (int)self.rightPlayer.fantasyPoints) self.rightPointsBackground.backgroundColor = [UIColor FBBlueHighlightColor];
        else self.rightPointsBackground.backgroundColor = [UIColor FBRedHighlightColor];
        self.rightPointsView.text = [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints];
        [self highlightRightScore];
    }
    if (!self.leftPlayer.isPlaying) self.leftPointsView.text = @"-";
    else if (![self.leftPointsView.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints]]) {
        if (self.leftPointsView.text.intValue <= (int)self.leftPlayer.fantasyPoints) self.leftPointsBackground.backgroundColor = [UIColor FBBlueHighlightColor];
        else self.leftPointsBackground.backgroundColor = [UIColor FBRedHighlightColor];
        self.leftPointsView.text = [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints];
        [self highlightLeftScore];
    }
    if (self.rightPlayer.gameState == FBGameStateHasntStarted) self.rightPointsView.textColor = [UIColor lightGrayColor];
    else self.rightPointsView.textColor = [UIColor blackColor];
    if (self.leftPlayer.gameState == FBGameStateHasntStarted) self.leftPointsView.textColor = [UIColor lightGrayColor];
    else self.leftPointsView.textColor = [UIColor blackColor];
}

- (void)loadWinProbabilityRightPlayer:(FBWinProbablityPlayer *)wpRightPlayer leftPlayer:(FBWinProbablityPlayer *)wpLeftPlayer {
    if (!self.expanded) return;
    if (!self.rightScores) {
        self.rightScores = [[NSMutableArray alloc] init];
        self.leftScores = [[NSMutableArray alloc] init];
        for (int i = 0; i < wpLeftPlayer.games.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10+20*i, 50, 15, 15)];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:8 weight:UIFontWeightSemibold];
            label.layer.cornerRadius = 7.5;
            label.clipsToBounds = YES;
            label.text = @[@"M",@"T",@"W",@"T",@"F",@"S",@"S"][i];
            [self addSubview:label];
            [self.leftScores addObject:label];
        }
        for (int i = 0; i < wpRightPlayer.games.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.size.width-20*7-10+20*i, 50, 15, 15)];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:8 weight:UIFontWeightSemibold];
            label.layer.cornerRadius = 7.5;
            label.clipsToBounds = YES;
            label.text = @[@"M",@"T",@"W",@"T",@"F",@"S",@"S"][i];
            [self addSubview:label];
            [self.rightScores addObject:label];
        }
    }
    for (int i = 0; i < self.rightScores.count; i++) {
        if ([wpRightPlayer.games[i] class] != [NSNull class])  {
            self.rightScores[i].textColor = [UIColor whiteColor];
            if (((FBWinProbabilityGame *)wpRightPlayer.games[i]).progress == 0)
                self.rightScores[i].backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
            else {
                float STDoff = (((FBWinProbabilityGame *)wpRightPlayer.games[i]).score-wpRightPlayer.average)/wpRightPlayer.standardDeviation;
                //if (STDoff > 0)
                //     self.rightScores[i].backgroundColor = [UIColor colorWithHue:91/360.0 saturation:1 brightness:.90-.2*STDoff alpha:1];
                //else self.rightScores[i].backgroundColor = [UIColor colorWithHue:0/360.0 saturation:1 brightness:.90+.1*STDoff alpha:1];
                if (STDoff > 0)
                    self.rightScores[i].backgroundColor = [UIColor colorWithHue:110/360.0 saturation:1 brightness:.6 alpha:MIN(1,.5+.3*STDoff)];
                else self.rightScores[i].backgroundColor = [UIColor colorWithHue:0/360.0 saturation:1 brightness:.9 alpha:MIN(1,.5-.2*STDoff)];
                self.rightScores[i].text = [NSString stringWithFormat:@"%d",((FBWinProbabilityGame *)wpRightPlayer.games[i]).score];
            }
        }
    }
    for (int i = 0; i < self.leftScores.count; i++) {
        if ([wpLeftPlayer.games[i] class] != [NSNull class]) {
            self.leftScores[i].textColor = [UIColor whiteColor];
            if (((FBWinProbabilityGame *)wpLeftPlayer.games[i]).progress == 0)
                self.leftScores[i].backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
            else {
                float STDoff = (((FBWinProbabilityGame *)wpLeftPlayer.games[i]).score-wpLeftPlayer.average)/wpLeftPlayer.standardDeviation;
                //if (STDoff > 0)
                //    self.leftScores[i].backgroundColor = [UIColor colorWithHue:91/360.0 saturation:1 brightness:.9-.2*STDoff alpha:1];
                //else self.leftScores[i].backgroundColor = [UIColor colorWithHue:0/360.0 saturation:1 brightness:.9+.1*STDoff alpha:1];
                if (STDoff > 0)
                    self.leftScores[i].backgroundColor = [UIColor colorWithHue:110/360.0 saturation:1 brightness:.6 alpha:MIN(1,.5+.3*STDoff)];
                else self.leftScores[i].backgroundColor = [UIColor colorWithHue:0/360.0 saturation:1 brightness:.9 alpha:MIN(1,.5-.2*STDoff)];
                self.leftScores[i].text = [NSString stringWithFormat:@"%d",((FBWinProbabilityGame *)wpLeftPlayer.games[i]).score];
            }

        }
    }
}

- (NSString *)statsForPlayer: (FBPlayer *)player expanded: (BOOL)expanded {
    NSArray *strList = (expanded) ? @[@" pts",@" reb",@" ast",@" stl",@" blk"] : @[@"p",@"r",@"a",@"s",@"b"];
    int stat1 = 0, stat2 = 0;
    NSString *stat1t = @"", *stat2t = @""; //pick largest stats of: reb, ast, blk, stl
    if ((int)player.blocks >= (int)player.assists ||
        (int)player.steals > (int)player.assists ||
        (int)player.steals > (int)player.rebounds) {
        if ((int)player.rebounds >= (int)player.assists) {
            stat1 = player.rebounds;
            stat1t = strList[1];
        }
        else {
            stat1 = player.assists;
            stat1t = strList[2];
        }
        if ((int)player.blocks >= (int)player.steals) {
            stat2 = player.blocks;
            stat2t = strList[4];
        }
        else {
            stat2 = player.steals;
            stat2t = strList[3];
        }
    }
    else {
        stat1 = player.rebounds;
        stat1t = strList[1];
        stat2 = player.assists;
        stat2t = strList[2];
    }
    NSString *str = [NSString stringWithFormat:@"%.0f%@, %d%@, %d%@",player.points,strList[0],stat1,stat1t,stat2,stat2t];
    return (self.expanded) ? [[NSString stringWithFormat:@"%.0f/%.0f, ",player.fgm,player.fga] stringByAppendingString:str] : str;
    
}

- (void)highlightLeftScore {
    self.leftPointsBackground.alpha = 1.0;
    [self performSelector:@selector(unhighlightLeftScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightLeftScore {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:3.5 animations:^{
        self.leftPointsBackground.alpha = 0.0;
    }];
};

- (void)highlightRightScore {
    self.rightPointsBackground.alpha = 1.0;
    [self performSelector:@selector(unhighlightRightScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightRightScore {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:3.5 animations:^{
        self.rightPointsBackground.alpha = 0.0;
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
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

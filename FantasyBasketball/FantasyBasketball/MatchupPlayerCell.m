//
//  MatchupPlayerCell.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/28/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MatchupPlayerCell.h"

@interface MatchupPlayerCell()

@property (weak, nonatomic) IBOutlet UIButton *rightLinkButton;
@property (weak, nonatomic) IBOutlet UIButton *leftLinkButton;

@property (weak, nonatomic) IBOutlet UILabel *rightNameView;
@property (weak, nonatomic) IBOutlet UILabel *leftNameView;

@property (weak, nonatomic) IBOutlet UILabel *rightSubnameView;
@property (weak, nonatomic) IBOutlet UILabel *leftSubnameView;

@property (weak, nonatomic) IBOutlet UILabel *rightSubname2View;
@property (weak, nonatomic) IBOutlet UILabel *leftSubname2View;

@property (weak, nonatomic) IBOutlet UILabel *rightInjuryView;
@property (weak, nonatomic) IBOutlet UILabel *leftInjuryView;

@property (weak, nonatomic) IBOutlet UIButton *rightPointsView;
@property (weak, nonatomic) IBOutlet UIButton *leftPointsView;

@property (weak, nonatomic) IBOutlet UILabel *rightProjectionsView;
@property (weak, nonatomic) IBOutlet UILabel *leftProjectionsView;

@property (nonatomic) BOOL expanded;

@end

@implementation MatchupPlayerCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)loadWithRightPlayer:(FBPlayer *)rP leftPlayer:(FBPlayer *)lP expanded:(bool)expanded {
    self.expanded = expanded;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.rightPlayer = rP;
    self.leftPlayer = lP;
    if (self.leftPlayer) {
        //NAME
        self.leftNameView.text = [NSString stringWithFormat:@"%@. %@",[self.leftPlayer.firstName substringToIndex:1],self.leftPlayer.lastName];
        //POINTS
        [self.leftPointsView setTitle:(self.leftPlayer.isPlaying) ?
              [NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints] : @"-" forState:UIControlStateNormal];
        if (self.leftPlayer.isPlaying)
            [self.leftPointsView addTarget:self action:@selector(linkGameLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (self.leftPlayer.gameState == FBGameStateHasntStarted)
            [self.leftPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.2] forState:UIControlStateNormal];
        else [self.leftPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.6] forState:UIControlStateNormal];
        //INJURY
        if (![self.leftPlayer.injury isEqualToString:@""])
            self.leftInjuryView.text = self.leftPlayer.injury;
        //INFO
        NSString *playerStats = [self statsForPlayer:self.leftPlayer expanded:(self.expanded)];
        if (self.leftPlayer.isPlaying)
            self.leftSubnameView.text = (self.expanded) ?
                [NSString stringWithFormat:@"%@, %@ %@",self.leftPlayer.opponent,self.leftPlayer.status,self.leftPlayer.score] :
                [NSString stringWithFormat:@"%@: %@",self.leftPlayer.status, playerStats];
        else self.leftSubnameView.text = @"-";
        if (self.expanded && self.leftPlayer.gameState != FBGameStateHasntStarted)
            self.leftSubname2View.text = playerStats;
        //Link
        [self.leftLinkButton addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.rightPlayer) {
        //NAME
        self.rightNameView.text = [NSString stringWithFormat:@"%@. %@",[self.rightPlayer.firstName substringToIndex:1],self.rightPlayer.lastName];
        //POINTS
        [self.rightPointsView setTitle:(self.rightPlayer.isPlaying) ?
         [NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints] : @"-" forState:UIControlStateNormal];
        if (self.rightPlayer.isPlaying)
            [self.rightPointsView addTarget:self action:@selector(linkGameLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (self.rightPlayer.gameState == FBGameStateHasntStarted)
            [self.rightPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.2] forState:UIControlStateNormal];
        else [self.rightPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.6] forState:UIControlStateNormal];
        //INJURY
        if (![self.rightPlayer.injury isEqualToString:@""])
            self.rightInjuryView.text = self.rightPlayer.injury;
        //INFO
        NSString *playerStats = [self statsForPlayer:self.rightPlayer expanded:(self.expanded)];
        if (self.rightPlayer.isPlaying)
            self.rightSubnameView.text = (self.expanded) ?
            [NSString stringWithFormat:@"%@, %@ %@",self.rightPlayer.opponent,self.rightPlayer.status,self.rightPlayer.score] :
            [NSString stringWithFormat:@"%@: %@",self.rightPlayer.status, playerStats];
        else self.rightSubnameView.text = @"-";
        if (self.expanded && self.rightPlayer.gameState != FBGameStateHasntStarted)
            self.rightSubname2View.text = playerStats;
        //Link
        [self.rightLinkButton addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
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
    if (!self.rightPlayer.isPlaying) [self.rightPointsView setTitle:@"-" forState:UIControlStateNormal];
    else if (![self.rightPointsView.titleLabel.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints]]) {
        if (self.rightPointsView.titleLabel.text.intValue <= (int)self.rightPlayer.fantasyPoints)
            self.rightPointsView.backgroundColor = [UIColor FBBlueHighlightColor];
        else self.rightPointsView.backgroundColor = [UIColor FBRedHighlightColor];
        [self.rightPointsView setTitle:[NSString stringWithFormat:@"%.0f",self.rightPlayer.fantasyPoints] forState:UIControlStateNormal];
        [self highlightRightScore];
    }
    if (!self.leftPlayer.isPlaying) [self.leftPointsView setTitle:@"-" forState:UIControlStateNormal];
    else if (![self.leftPointsView.titleLabel.text isEqualToString:[NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints]]) {
        if (self.leftPointsView.titleLabel.text.intValue <= (int)self.leftPlayer.fantasyPoints)
            self.leftPointsView.backgroundColor = [UIColor FBBlueHighlightColor];
        else self.leftPointsView.backgroundColor = [UIColor FBRedHighlightColor];
        [self.leftPointsView setTitle:[NSString stringWithFormat:@"%.0f",self.leftPlayer.fantasyPoints] forState:UIControlStateNormal];
        [self highlightLeftScore];
    }
    if (self.rightPlayer.gameState == FBGameStateHasntStarted)
         [self.rightPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.2] forState:UIControlStateNormal];
    else [self.rightPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.6] forState:UIControlStateNormal];
    if (self.leftPlayer.gameState == FBGameStateHasntStarted)
         [self.leftPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.2] forState:UIControlStateNormal];
    else [self.leftPointsView setTitleColor:[UIColor colorWithWhite:0 alpha:.6] forState:UIControlStateNormal];
}

- (void)loadWinProbabilityRightPlayer:(FBWinProbablityPlayer *)wpRightPlayer leftPlayer:(FBWinProbablityPlayer *)wpLeftPlayer {
    if (!self.expanded) return;
    NSMutableAttributedString *rightStr = [[NSMutableAttributedString alloc] initWithString:@"● ● ● ● ● ● ●"];
    for (int i = 0; i < 7; i++) {
        UIColor *color = [UIColor colorWithWhite:.7 alpha:1];
        if ([wpRightPlayer.games[i] class] != [NSNull class]) {
            float progress = ((FBWinProbabilityGame *)wpRightPlayer.games[i]).progress;
            if (progress > 0 && progress < 1) color = [UIColor blueColor];
            else if (progress == 1) {
                float STDoff = (((FBWinProbabilityGame *)wpRightPlayer.games[i]).score-wpRightPlayer.average)/wpRightPlayer.standardDeviation;
                color = (STDoff >= 0) ? [UIColor greenColor] : [UIColor redColor];
            }
        }
        else color = [UIColor colorWithWhite:.7 alpha:.2];
        [rightStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(i*2, 1)];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    [rightStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, rightStr.length)];
    self.rightProjectionsView.attributedText = rightStr;
    NSMutableAttributedString *leftStr = [[NSMutableAttributedString alloc] initWithString:@"● ● ● ● ● ● ●"];
    for (int i = 0; i < 7; i++) {
        UIColor *color = [UIColor colorWithWhite:.7 alpha:1];
        if ([wpLeftPlayer.games[i] class] != [NSNull class]) {
            float progress = ((FBWinProbabilityGame *)wpLeftPlayer.games[i]).progress;
            if (progress > 0 && progress < 1) color = [UIColor blueColor];
            else if (progress == 1) {
                float STDoff = (((FBWinProbabilityGame *)wpLeftPlayer.games[i]).score-wpLeftPlayer.average)/wpLeftPlayer.standardDeviation;
                color = (STDoff > 0) ? [UIColor greenColor] : [UIColor redColor];
            }
        }
        else color = [UIColor colorWithWhite:.7 alpha:.2];
        [leftStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(i*2, 1)];
    }
    self.leftProjectionsView.attributedText = leftStr;
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    self.rightSubname2View.alpha = expanded;
    self.leftSubname2View.alpha = expanded;
    self.rightProjectionsView.alpha = expanded;
    self.leftProjectionsView.alpha = expanded;
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
    self.leftPointsView.alpha = 1.0;
    [self performSelector:@selector(unhighlightLeftScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightLeftScore {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:3.5 animations:^{
        self.leftPointsView.backgroundColor = [UIColor whiteColor];
    }];
};

- (void)highlightRightScore {
    self.rightPointsView.alpha = 1.0;
    [self performSelector:@selector(unhighlightRightScore) withObject:nil afterDelay:1.5];
}

- (void)unhighlightRightScore {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:3.5 animations:^{
        self.rightPointsView.backgroundColor = [UIColor clearColor];
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

@end

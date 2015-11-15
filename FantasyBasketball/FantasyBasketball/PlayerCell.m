//
//  PlayerCellPL.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 2/26/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "PlayerCell.h"

@implementation PlayerCell {
    UIScrollView *scrollView;
}

//CellType: MyTeamViewController, PlayersViewController, DailyLeadersViewController

- (instancetype) initWithPlayer:(FBPlayer *)pl view:(UIViewController<UIScrollViewDelegate> *)superview scrollDistance:(float)dist size:(CGSize)size{
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        NSString *playerType = [NSString stringWithFormat:@"%@",superview.class];
        self.player = pl;
        bool isMTVC = [playerType isEqual:@"MyTeamViewController"];
        bool isPLVC = [playerType isEqual:@"PlayersViewController"];
        bool isLarge = size.width > 400;
        //NAME
        UILabel *name;
        if (isMTVC) name = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 25)]:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 25)];
        else name = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 25)]:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
        name.font = isLarge ? [UIFont systemFontOfSize:17]:[UIFont systemFontOfSize:15];
        name.text = [NSString stringWithFormat:@"  %@. %@",[self.player.firstName substringToIndex:1],self.player.lastName];
        [self addSubview:name];
        //INFO
        UILabel *subName = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 90, 20)]:[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 85, 20)];
        subName.font = [subName.font fontWithSize:11];
        subName.textColor = [UIColor grayColor];
        subName.text = [NSString stringWithFormat:@"   %@, %@",self.player.team,self.player.position];
        [self addSubview:subName];
        //Injury
        if (![self.player.injury isEqualToString:@""]) {
            UILabel *injury = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(90, 20, 30, 20)]:[[UILabel alloc] initWithFrame:CGRectMake(85, 20, 30, 20)];
            injury.font = [UIFont boldSystemFontOfSize:11];
            injury.textColor = [UIColor redColor];
            injury.textAlignment = NSTextAlignmentCenter;
            injury.text = self.player.injury;
            [self addSubview:injury];
        }
        //TYPE
        if (!isMTVC) {
            UILabel *type = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(120, 7, 60, 25)]:[[UILabel alloc] initWithFrame:CGRectMake(105, 7, 50, 25)];
            type.font = isLarge ? [UIFont systemFontOfSize:17]:[UIFont systemFontOfSize:13];
            type.text = [NSString stringWithFormat:@"%@",self.player.type];
            if ([type.text isEqual:@"FA"]) {
                type.textColor = [UIColor FBGreenColor];
            }
            else if ([type.text containsString:@"WA-"]) {
                type.textColor = [UIColor FBYellowColor];
            }
            type.textAlignment = NSTextAlignmentCenter;
            [self addSubview:type];
        }
        //Link
        UIButton *link;
        if (isMTVC) link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, size.height)];
        else link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, size.height)];
        [link addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
        link.backgroundColor = [UIColor clearColor];
        link.titleLabel.text = @"";
        [self addSubview:link];
        //Divider
        UILabel *div;
        if (isMTVC) div = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(130-1, 0, 1, size.height)]:[[UILabel alloc] initWithFrame:CGRectMake(115-1, 0, 1, size.height)];
        else div = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(180-1, 0, 1, size.height)]:[[UILabel alloc] initWithFrame:CGRectMake(150-1, 0, 1, size.height)];
        div.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:div];
        //STATS SCROLLVIEW
        if (isMTVC) {
            scrollView = isLarge ? [[UIScrollView alloc] initWithFrame:CGRectMake(130, 0, size.width-130, size.height)]:
                                   [[UIScrollView alloc] initWithFrame:CGRectMake(115, 0, size.width-115, size.height)];
            [scrollView setContentSize:CGSizeMake(13*50+120, size.height)];
        }
        else if (isPLVC) {
            scrollView = isLarge ? [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, size.width-180, size.height)]:
                                   [[UIScrollView alloc] initWithFrame:CGRectMake(150, 0, size.width-150, size.height)];
            [scrollView setContentSize:CGSizeMake(14*50+120, size.height)];
        }
        else {
            scrollView = isLarge ? [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, size.width-180, size.height)]:
                                   [[UIScrollView alloc] initWithFrame:CGRectMake(150, 0, size.width-150, size.height)];
            [scrollView setContentSize:CGSizeMake(12*50+120, size.height)];
        }
        [scrollView setContentOffset:CGPointMake(dist, 0)];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setBounces:NO];
        [self addSubview:scrollView];
        scrollView.delegate = superview;
        scrollView.tag = 1;
        //STATS LABELS
        if (self.player.isPlaying) {
            UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 120, 25)];
            stats1.font = [UIFont systemFontOfSize:14.0];
            stats1.textColor = [UIColor grayColor];
            stats1.text = [NSString stringWithFormat:@"%@: %@",self.player.opponent, self.player.status];
            [scrollView addSubview:stats1];
            if (!isMTVC && (self.player.gameState == FBGameStateInProgress || self.player.gameState == FBGameStateEnded)) {
                UILabel *stats2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 120, 20)];
                stats2.font = [subName.font fontWithSize:14.0];
                stats2.textColor = [UIColor grayColor];
                stats2.text = [NSString stringWithFormat:@"%@: %.0f + %.0f",self.player.score,self.player.points-(self.player.fta-self.player.ftm)-(self.player.fga-self.player.fgm), self.player.rebounds+self.player.assists+self.player.blocks+self.player.steals-self.player.turnovers];
                [scrollView addSubview:stats2];
            }
        }
        if (isMTVC) {
            float arr2[13] = {self.player.fantasyPoints,self.player.fgm,self.player.fga,self.player.ftm,self.self.player.fta,self.player.rebounds,self.player.assists,self.player.blocks,self.player.steals,self.player.turnovers,self.player.points,self.player.percentOwned,self.player.plusMinus};
            for (int i = 0; i < 11; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+120, 0, 50, size.height)];
                if (![@"today" isEqual:@"today"]) stats.text = [NSString stringWithFormat:@"%.1f",arr2[i]]; //NEED TO WORK ON THIS **************************
                else if (!self.player.isPlaying) stats.text = @"-";
                else stats.text = [NSString stringWithFormat:@"%.0f",arr2[i]];
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*11+120, 0, 50, size.height)];
            stats.text = [NSString stringWithFormat:@"%.1f",arr2[11]];
            stats.textAlignment = NSTextAlignmentCenter;
            [scrollView addSubview:stats];
            stats = [[UILabel alloc] initWithFrame:CGRectMake(50*12+120, 0, 50, size.height)];
            stats.textAlignment = NSTextAlignmentCenter;
            if (arr2[12] > 0) {
                stats.text = [NSString stringWithFormat:@"+%.1f",arr2[12]];
                stats.textColor = [UIColor FBGreenColor];
            }
            else if (arr2[12] == 0) stats.text = @"0.0";
            else {
                stats.text = [NSString stringWithFormat:@"%.1f",arr2[12]];
                stats.textColor = [UIColor FBRedColor];
            }
            [scrollView addSubview:stats];
        }
        else if (isMTVC) {
            float arr2[14] = {self.player.fantasyPoints,self.player.totalFantasyPoints,self.player.percentOwned,self.player.plusMinus,self.player.fgm,self.player.fga,self.player.ftm,self.player.fta,self.player.rebounds,self.player.assists,self.player.blocks,self.player.steals,self.player.turnovers,self.player.points};
            for (int i = 0; i < 14; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+120, 0, 50, size.height)];
                stats.text = [NSString stringWithFormat:@"%.1f",arr2[i]];
                if (i == 1) stats.text = [NSString stringWithFormat:@"%.0f",arr2[i]];
                if (i == 3) {
                    if (self.player.plusMinus > 0) {
                        stats.textColor = [UIColor FBGreenColor];
                        stats.text = [NSString stringWithFormat:@"+%@",stats.text];
                    }
                    else if (self.player.plusMinus < 0) stats.textColor = [UIColor FBRedColor];
                }
                //if (i == sortIndex) stats.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f]; //sorted row
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
        }
        else {
            float arr2[12] = {self.player.fantasyPoints,self.player.min,self.player.fgm,self.player.fga,self.player.ftm,self.player.fta,self.player.rebounds,self.player.assists,self.player.blocks,self.player.steals,self.player.turnovers,self.player.points};
            for (int i = 0; i < 12; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+120, 0, 50, size.height)];
                if (!self.player.isPlaying) stats.text = @"-";
                else stats.text = [NSString stringWithFormat:@"%.0f",arr2[i]];
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
        }
        //Game link
        UIButton *gLink = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, size.height)];
        if (self.player.isPlaying) [gLink addTarget:self action:@selector(linkGameLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
        gLink.backgroundColor = [UIColor clearColor];
        gLink.titleLabel.text = @"";
        [scrollView addSubview:gLink];
    }
    return self;
}

- (void)setScrollDistance:(float)dist {
    [scrollView setContentOffset:CGPointMake(dist, 0)];
}

- (void)linkGameLinkPressed:(UIButton *)sender {
    [self.delegate linkWithGameLink:self.player];
}

- (void)linkPlayerPressed:(UIButton *)sender {
    [self.delegate linkWithPlayer:self.player];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

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

- (instancetype) initWithPlayer:(Player *)pl view:(UIViewController<UIScrollViewDelegate> *)superview scrollDistance:(float)dist {
    if (self = [super initWithFrame:CGRectMake(0, 0, 414, 40)]) {
        NSString *playerType = [NSString stringWithFormat:@"%@",superview.class];
        self.player = pl;
        //NAME
        UILabel *name;
        if ([playerType isEqual:@"MyTeamViewController"]) name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 25)];
        else name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 25)];
        name.text = [NSString stringWithFormat:@"  %@. %@",[self.player.firstName substringToIndex:1],self.player.lastName];
        [self addSubview:name];
        //INFO
        UILabel *subName = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 90, 20)];
        subName.font = [subName.font fontWithSize:11];
        subName.textColor = [UIColor grayColor];
        subName.text = [NSString stringWithFormat:@"   %@, %@",self.player.team,self.player.position];
        [self addSubview:subName];
        //Injury
        if (![self.player.injury isEqualToString:@""]) {
            UILabel *injury = [[UILabel alloc] initWithFrame:CGRectMake(90, 20, 30, 20)];
            injury.font = [UIFont boldSystemFontOfSize:11];
            injury.textColor = [UIColor redColor];
            injury.textAlignment = NSTextAlignmentCenter;
            injury.text = self.player.injury;
            [self addSubview:injury];
        }
        //TYPE
        if (![playerType isEqual:@"MyTeamViewController"]) {
            UILabel *type = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, 60, 25)];
            type.text = [NSString stringWithFormat:@"%@",self.player.type];
            if ([type.text isEqual:@"FA"]) {
                type.textColor = [UIColor colorWithRed:0/255.0f green:190/255.0f blue:0/255.0f alpha:1.0f]; //green
            }
            else if ([type.text containsString:@"WA-"]) {
                type.textColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:40/255.0f alpha:1.0f]; //yellow
            }
            type.textAlignment = NSTextAlignmentCenter;
            [self addSubview:type];
        }
        //Link
        UIButton *link;
        if ([playerType isEqual:@"MyTeamViewController"]) link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 129, 40)];
        else link = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 179, 40)];
        [link addTarget:self action:@selector(linkPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
        link.backgroundColor = [UIColor clearColor];
        link.titleLabel.text = @"";
        [self addSubview:link];
        //Divider
        UILabel *div;
        if ([playerType isEqual:@"MyTeamViewController"]) div = [[UILabel alloc] initWithFrame:CGRectMake(129, 0, 1, 40)];
        else div = [[UILabel alloc] initWithFrame:CGRectMake(179, 0, 1, 40)];
        div.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:div];
        //STATS SCROLLVIEW
        if ([playerType isEqual:@"MyTeamViewController"]) {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(130, 0, 414-130, 40)];
            [scrollView setContentSize:CGSizeMake(13*50+150, 40)];
        }
        else if ([playerType isEqual:@"PlayersViewController"]) {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, 414-180, 40)];
            [scrollView setContentSize:CGSizeMake(14*50+150, 40)];
        }
        else {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, 414-180, 40)];
            [scrollView setContentSize:CGSizeMake(12*50+150, 40)];
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
            UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 140, 25)];
            stats1.text = [NSString stringWithFormat:@"%@: %@",self.player.opponent, self.player.status];
            [scrollView addSubview:stats1];
            if (![playerType isEqual:@"PlayersViewController"] && (self.player.gameInProgress || self.player.gameEnded)) {
                UILabel *stats2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 140, 20)];
                stats2.font = [subName.font fontWithSize:11];
                stats2.textColor = [UIColor grayColor];
                stats2.text = [NSString stringWithFormat:@"%@: %.0f + %.0f",self.player.score,self.player.points-(self.player.fta-self.player.ftm)-(self.player.fga-self.player.fgm), self.player.rebounds+self.player.assists+self.player.blocks+self.player.steals-self.player.turnovers];
                [scrollView addSubview:stats2];
            }
        }
        if ([playerType isEqual:@"MyTeamViewController"]) {
            float arr2[13] = {self.player.fantasyPoints,self.player.fgm,self.player.fga,self.player.ftm,self.self.player.fta,self.player.rebounds,self.player.assists,self.player.blocks,self.player.steals,self.player.turnovers,self.player.points,self.player.percentOwned,self.player.plusMinus};
            for (int i = 0; i < 11; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, 40)];
                if (![@"today" isEqual:@"today"]) stats.text = [NSString stringWithFormat:@"%.1f",arr2[i]]; //NEED TO WORK ON THIS **************************
                else if (!self.player.isPlaying) stats.text = @"-";
                else stats.text = [NSString stringWithFormat:@"%.0f",arr2[i]];
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*11+150, 0, 50, 40)];
            stats.text = [NSString stringWithFormat:@"%.1f",arr2[11]];
            stats.textAlignment = NSTextAlignmentCenter;
            [scrollView addSubview:stats];
            stats = [[UILabel alloc] initWithFrame:CGRectMake(50*12+150, 0, 50, 40)];
            stats.textAlignment = NSTextAlignmentCenter;
            if (arr2[12] > 0) {
                stats.text = [NSString stringWithFormat:@"+%.1f",arr2[12]];
                stats.textColor = [UIColor colorWithRed:0/255.0f green:190/255.0f blue:0/255.0f alpha:1.0f]; //green
            }
            else if (arr2[12] == 0) stats.text = @"0.0";
            else {
                stats.text = [NSString stringWithFormat:@"%.1f",arr2[12]];
                stats.textColor = [UIColor colorWithRed:240/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f]; //red
            }
            [scrollView addSubview:stats];
        }
        else if ([playerType isEqual:@"PlayersViewController"]) {
            float arr2[14] = {self.player.fantasyPoints,self.player.totalFantasyPoints,self.player.percentOwned,self.player.plusMinus,self.player.fgm,self.player.fga,self.player.ftm,self.player.fta,self.player.rebounds,self.player.assists,self.player.blocks,self.player.steals,self.player.turnovers,self.player.points};
            for (int i = 0; i < 14; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, 40)];
                stats.text = [NSString stringWithFormat:@"%.1f",arr2[i]];
                if (i == 1) stats.text = [NSString stringWithFormat:@"%.0f",arr2[i]];
                if (i == 3) {
                    if (self.player.plusMinus > 0) {
                        stats.textColor = [UIColor colorWithRed:0/255.0f green:190/255.0f blue:0/255.0f alpha:1.0f]; //green
                        stats.text = [NSString stringWithFormat:@"+%@",stats.text];
                    }
                    else if (self.player.plusMinus < 0) stats.textColor = [UIColor colorWithRed:240/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f]; //red
                }
                //if (i == sortIndex) stats.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f]; //sorted row
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
        }
        else {
            float arr2[12] = {self.player.fantasyPoints,self.player.min,self.player.fgm,self.player.fga,self.player.ftm,self.player.fta,self.player.rebounds,self.player.assists,self.player.blocks,self.player.steals,self.player.turnovers,self.player.points};
            for (int i = 0; i < 12; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, 40)];
                if (!self.player.isPlaying) stats.text = @"-";
                else stats.text = [NSString stringWithFormat:@"%.0f",arr2[i]];
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
        }
        //Game link
        UIButton *gLink = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
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

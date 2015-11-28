//
//  ScoreboardCell.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/28/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "ScoreboardCell.h"

@implementation ScoreboardCell {
    UILabel *rightNameView;
    UILabel *leftNameView;
    
    UILabel *rightSubnameView;
    UILabel *leftSubnameView;
    
    UILabel *rightPointsView;
    UIView *rightPointsBackground;
    UILabel *leftPointsView;
    UIView *leftPointsBackground;
}

- (instancetype) initWithMatchup: (NSDictionary *)matchup view:(UIViewController *)superview size:(CGSize)size {
    self.matchup = matchup;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        //background
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(10, 5, size.width-20, 120-10)];
        background.backgroundColor = [UIColor FBMediumOrangeColor];
        background.layer.cornerRadius = 5;
        [self addSubview:background];
        //left name
        leftNameView = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, (size.width-20)/2-10, 30)];
        leftNameView.text = matchup[@"teams"][0][@"name"];
        leftNameView.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        leftNameView.textAlignment = NSTextAlignmentCenter;
        leftNameView.textColor = [UIColor whiteColor];
        leftNameView.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:leftNameView];
        //left subname
        leftSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, (size.width-20)/2-10, 20)];
        leftSubnameView.text = [NSString stringWithFormat:@"%@ (%@)",matchup[@"teams"][0][@"manager"],matchup[@"teams"][0][@"record"]];
        leftSubnameView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        leftSubnameView.textAlignment = NSTextAlignmentCenter;
        leftSubnameView.textColor = [UIColor whiteColor];
        leftSubnameView.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:leftSubnameView];
        //left score bg
        leftPointsBackground = [[UIView alloc] initWithFrame:CGRectMake(5, 55, (size.width-20)/2-10, 40)];
        leftPointsBackground.alpha = 0.0;
        [background addSubview:leftPointsBackground];
        //left score
        leftPointsView = [[UILabel alloc] initWithFrame:CGRectMake(5, 55, (size.width-20)/2-10, 40)];
        leftPointsView.text = matchup[@"teams"][0][@"score"];
        leftPointsView.font = [UIFont systemFontOfSize:40 weight:UIFontWeightRegular];
        leftPointsView.textAlignment = NSTextAlignmentCenter;
        leftPointsView.textColor = [UIColor whiteColor];
        leftPointsView.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:leftPointsView];
        //right name
        rightNameView = [[UILabel alloc] initWithFrame:CGRectMake(size.width-(size.width-20)/2-10-5, 5, (size.width-20)/2-10, 30)];
        rightNameView.text = matchup[@"teams"][1][@"name"];
        rightNameView.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        rightNameView.textAlignment = NSTextAlignmentCenter;
        rightNameView.textColor = [UIColor whiteColor];
        rightNameView.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:rightNameView];
        //right subname
        rightSubnameView = [[UILabel alloc] initWithFrame:CGRectMake(size.width-(size.width-20)/2-10-5, 30, (size.width-20)/2-10, 20)];
        rightSubnameView.text = [NSString stringWithFormat:@"%@ (%@)",matchup[@"teams"][1][@"manager"],matchup[@"teams"][1][@"record"]];
        rightSubnameView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        rightSubnameView.textAlignment = NSTextAlignmentCenter;
        rightSubnameView.textColor = [UIColor whiteColor];
        rightSubnameView.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:rightSubnameView];
        //left score bg
        rightPointsBackground = [[UIView alloc] initWithFrame:CGRectMake(size.width-(size.width-20)/2-10-5, 55, (size.width-20)/2-10, 40)];
        rightPointsBackground.alpha = 0.0;
        [background addSubview:rightPointsBackground];
        //right score
        rightPointsView = [[UILabel alloc] initWithFrame:CGRectMake(size.width-(size.width-20)/2-10-5, 55, (size.width-20)/2-10, 40)];
        rightPointsView.text = matchup[@"teams"][1][@"score"];
        rightPointsView.font = [UIFont systemFontOfSize:40 weight:UIFontWeightRegular];
        rightPointsView.textAlignment = NSTextAlignmentCenter;
        rightPointsView.textColor = [UIColor whiteColor];
        rightPointsView.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [background addSubview:rightPointsView];
    }
    return self;
}

- (void)updateWithMatchup: (NSDictionary *) matchup {
    self.matchup = matchup;
    if (![rightPointsView.text isEqualToString:self.matchup[@"teams"][1][@"score"]]) {
        if (rightPointsView.text.intValue <= [self.matchup[@"teams"][1][@"score"] intValue])
            rightPointsBackground.backgroundColor = [UIColor FBBlueHighlightColor];
        else rightPointsBackground.backgroundColor = [UIColor FBRedHighlightColor];
        rightPointsView.text = self.matchup[@"teams"][1][@"score"];
        [self highlightRightScore];
    }
    if (![leftPointsView.text isEqualToString:self.matchup[@"teams"][0][@"score"]]) {
        if (leftPointsView.text.intValue <= [self.matchup[@"teams"][0][@"score"] intValue])
            leftPointsBackground.backgroundColor = [UIColor FBBlueHighlightColor];
        else leftPointsBackground.backgroundColor = [UIColor FBRedHighlightColor];
        leftPointsView.text = self.matchup[@"teams"][0][@"score"];
        [self highlightLeftScore];
    }
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

- (void)linkMatchupLinkPressed:(UIButton *)sender {
    [self.delegate linkWithMatchupLink:self.matchup[@"link"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

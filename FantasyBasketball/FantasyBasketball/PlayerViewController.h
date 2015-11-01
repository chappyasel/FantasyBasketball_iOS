//
//  PlayerViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BEMSimpleLineGraphView;

@interface PlayerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *darkBackground;

@property (weak, nonatomic) IBOutlet UIImageView *playerImageView;
@property (weak, nonatomic) IBOutlet UIView *playerImageBG;

@property (weak, nonatomic) IBOutlet UILabel *playerNameDisplay;
@property (weak, nonatomic) IBOutlet UILabel *playerTeamDisplay;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *statSlot1Header;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *statSlot2Header;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *statSlot3Header;

@property (weak, nonatomic) IBOutlet UILabel *seasonDisplay1;
@property (weak, nonatomic) IBOutlet UILabel *seasonDisplay2;
@property (weak, nonatomic) IBOutlet UILabel *seasonDisplay3;

@property (weak, nonatomic) IBOutlet UILabel *careerDisplay1;
@property (weak, nonatomic) IBOutlet UILabel *careerDisplay2;
@property (weak, nonatomic) IBOutlet UILabel *careerDisplay3;

//nav bar

@property (weak, nonatomic) IBOutlet UIButton *tabButton1;
@property (weak, nonatomic) IBOutlet UIButton *tabButton2;
@property (weak, nonatomic) IBOutlet UIButton *tabButton3;
@property (weak, nonatomic) IBOutlet UIButton *tabButton4;
@property (weak, nonatomic) IBOutlet UIButton *tabButton5;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *titleView;
@property (weak, nonatomic) IBOutlet UIView *scrollIndicator;

//bottom half

@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) IBOutlet UILabel *graphNameDisplay;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;
@property (weak, nonatomic) IBOutlet UITableView *statsBasicTableView; //to remove
@property (weak, nonatomic) IBOutlet UITableView *gamesBasicTableView;

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) IBOutlet UITableView *gameTableView;
@property (strong, nonatomic) IBOutlet UIScrollView *statsScrollView;
@property (strong, nonatomic) IBOutlet UITableView *rotoworldTableView;

@end

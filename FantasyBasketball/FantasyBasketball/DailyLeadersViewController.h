//
//  DailyLeadersViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "FBViewController.h"
#import "PlayerCell.h"

@interface DailyLeadersViewController : FBViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, PlayerCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *autorefreshSwitch;

@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *pickerCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *pickerDoneButton;

@end

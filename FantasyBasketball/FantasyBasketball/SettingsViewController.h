//
//  SettingsViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBPickerView.h"
#import "FBSession.h"
#import "RESideMenu.h"

@interface SettingsViewController : UIViewController <UITextFieldDelegate, FBPickerViewDelegate>

@property (strong, nonatomic) FBSession *session;

@property (strong, nonatomic) IBOutlet UITextField *leagueInput;
@property (strong, nonatomic) IBOutlet UITextField *teamInput;
@property (strong, nonatomic) IBOutlet UITextField *seasonInput;
@property (strong, nonatomic) IBOutlet UITextField *scoringIDInput;


@end

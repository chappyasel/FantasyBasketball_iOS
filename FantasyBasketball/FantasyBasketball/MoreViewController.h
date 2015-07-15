//
//  MoreViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *leagueInput;
@property (weak, nonatomic) IBOutlet UITextField *teamInput;
@property (weak, nonatomic) IBOutlet UITextField *seasonInput;
@property (weak, nonatomic) IBOutlet UITextField *scoringIDInput;


@end

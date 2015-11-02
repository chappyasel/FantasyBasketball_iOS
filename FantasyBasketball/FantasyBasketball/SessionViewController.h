//
//  SessionViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/1/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSession.h"

@protocol SessionViewControllerDelegate <NSObject>
- (void)sessionVCDidDissapearWithResultSession:(FBSession *)session;
@end

@interface SessionViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <SessionViewControllerDelegate> delegate;

@property FBSession *session;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (strong, nonatomic) IBOutlet UITextField *leagueInput;
@property (strong, nonatomic) IBOutlet UITextField *teamInput;
@property (strong, nonatomic) IBOutlet UITextField *seasonInput;
@property (strong, nonatomic) IBOutlet UITextField *scoringIDInput;

@end

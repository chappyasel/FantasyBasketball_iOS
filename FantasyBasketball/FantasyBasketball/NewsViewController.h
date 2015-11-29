//
//  NewsViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBViewController.h"
#import "FBNewsSelectorView.h"
#import "FBNewsSettings.h"

@interface NewsViewController : FBViewController <FBNewsSelectorViewDelegate>

@property FBNewsSettings *newsSettings;

- (void)fadeOutWithPickerView: (FBNewsSelectorView *) selectorView;

@end

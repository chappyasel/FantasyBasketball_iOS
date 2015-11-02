//
//  SettingsViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

@property NSMutableArray <FBSession *> *sessions;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    [self fetchSessions];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)fetchSessions {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FBSession" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) NSLog(@"%@",error);
    if (fetchedObjects.count == 0) NSLog(@"FETCHED OBJECTS ERROR");
    self.sessions = [[NSMutableArray alloc] initWithArray:fetchedObjects];
}

- (IBAction)newButtonPressed:(UIButton *)sender {
    if (self.sessions.count > 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Teams"
                                                        message:@"Sorry, this app only allows you to store 10 teams for the purpose of memory management. Please delete a league to add a new league."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        FBSession *session = [NSEntityDescription insertNewObjectForEntityForName:@"FBSession" inManagedObjectContext:context];
        session.isSelected = NO;
        [self.sessions addObject:session];
        SessionViewController *modalVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ss"];
        modalVC.modalPresentationStyle = UIModalPresentationCustom;
        modalVC.session = session;
        modalVC.delegate = self;
        self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
        self.animator.dragable = NO;
        self.animator.bounces = YES;
        self.animator.behindViewAlpha = 0.8;
        self.animator.behindViewScale = 0.9;
        self.animator.transitionDuration = 0.5;
        self.animator.direction = ZFModalTransitonDirectionBottom;
        modalVC.transitioningDelegate = self.animator;
        [self presentViewController:modalVC animated:YES completion:nil];
    }
}

- (IBAction)deleteButtonPressed:(UIButton *)sender {
    if (self.sessions.count == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete"
                                                        message:@"You can not delete the final team. There must be at least one team."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        FBSession *session = self.sessions[sender.tag];
        [self.sessions removeObject:session];
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        [context deleteObject:session];
        [context save:nil];
        [self.tableView reloadData];
    }
}

#pragma mark - tableView dataSource

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    }
    FBSession *session = self.sessions[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",session.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"LeagueID: %@, TeamID: %@",session.leagueID,session.teamID];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    if (session.isSelected) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteButton.frame = CGRectMake(self.tableView.frame.size.width-100, 10, 80, 30);
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = indexPath.row;
    [cell addSubview:deleteButton];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (FBSession *session in self.sessions) session.isSelected = NO;
    self.sessions[indexPath.row].isSelected = YES;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionChangeNotification"
                                                        object:nil];
    [tableView reloadData];
}

#pragma mark - sessionVC delegate

- (void)sessionVCDidDissapearWithResultSession:(FBSession *)session {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    [context save:&error];
    if (error)NSLog(@"%@",error.description);
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Get the new view controller using [segue destinationViewController].
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end

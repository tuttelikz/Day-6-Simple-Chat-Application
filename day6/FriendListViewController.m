//
//  FriendListViewController.m
//  day6
//
//  Created by Student on 25.06.15.
//  Copyright (c) 2015 KBTU. All rights reserved.
//

#import "FriendListViewController.h"
#import <Parse/Parse.h>
#import "ChatViewController.h"
#import "FriendTableViewCell.h"

@interface FriendListViewController () <UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *friends;

@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.friends = [NSMutableArray new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self downloadFriends];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alert View

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:username];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                PFUser *user = (PFUser *)object;
                [self addFriend:user];
            }
        }];
    }
}

#pragma mark - Helper methods

-(void)addFriend:(PFUser *)friend
{
    PFObject *friendObject = [PFObject objectWithClassName:@"friends"];
    friendObject[@"friend1"] = [PFUser currentUser];
    friendObject[@"friend2"] = friend;
    [friendObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Friend added");
            [self downloadFriends];
        }
    }];
}

-(void)downloadFriends
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"friends"];
    [query1 whereKey:@"friend1" equalTo:[PFUser currentUser]];

    PFQuery *query2 = [PFQuery queryWithClassName:@"friends"];
    [query2 whereKey:@"friend2" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    
    [query includeKey:@"friend1"];
    [query includeKey:@"friend2"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            NSLog(@"Got friends");
            self.friends = [NSMutableArray new];
            for(PFObject *object in objects){
                if([object[@"friend1"][@"username"] isEqualToString:[PFUser currentUser][@"username"]]){
                    [self.friends addObject:object[@"friend2"]];
                }
                else {
                    [self.friends addObject:object[@"friend1"]];
                }
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    }
    
    PFUser *friend = self.friends[indexPath.row];
    cell.friendLabel.text = friend.username;
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"messages"];
    [query1 whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"receiver" equalTo:friend];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"messages"];
    [query2 whereKey:@"sender" equalTo:friend];
    [query2 whereKey:@"receiver" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    [query orderByDescending:@"createdAt"];

    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.messageLabel.text = object[@"text"];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"hh:mm"];
        cell.dateLabel.text = [formatter stringFromDate:[object createdAt]];
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *friend = self.friends[indexPath.row];
    ChatViewController *nextVC = [ChatViewController new];
    nextVC.friendUser = friend;
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - Button actions

- (IBAction)addFriendPressed:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add friend" message:@"Enter username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (IBAction)logoutPressed:(UIBarButtonItem *)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

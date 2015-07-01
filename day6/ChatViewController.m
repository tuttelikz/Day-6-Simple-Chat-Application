//
//  ChatViewController.m
//  day6
//
//  Created by Student on 25.06.15.
//  Copyright (c) 2015 KBTU. All rights reserved.
//

#import "ChatViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>

@interface ChatViewController ()

@property (nonatomic) NSMutableArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    //self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.messages = [NSMutableArray new];
    
    self.senderId = [[PFUser currentUser] objectId];
    self.senderDisplayName = [[PFUser currentUser] objectForKey:@"username"];

    [self downloadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods

-(void)downloadMessages
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"messages"];
    [query1 whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"receiver" equalTo:self.friendUser];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"messages"];
    [query2 whereKey:@"sender" equalTo:self.friendUser];
    [query2 whereKey:@"receiver" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.messages = [NSMutableArray new];
            for(PFObject *messageObject in objects){
                PFUser *sender = messageObject[@"sender"];
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[sender objectId] senderDisplayName:sender[@"username"] date:[messageObject createdAt] text:messageObject[@"text"]];
                [self.messages addObject:message];
            }
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - JSQ

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    [self.messages addObject:message];
    
    PFObject *messageObject = [PFObject objectWithClassName:@"messages"];
    messageObject[@"sender"] = [PFUser currentUser];
    messageObject[@"receiver"] = self.friendUser;
    messageObject[@"text"] = text;
    
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self finishSendingMessageAnimated:YES];
        if(succeeded == YES){
            NSLog(@"Saved message");
        }
    }];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.row];
    if([message.senderId isEqualToString:self.senderId]){
        return [[[JSQMessagesBubbleImageFactory alloc] init] outgoingMessagesBubbleImageWithColor:[UIColor grayColor]];
    }
    else {
        return [[[JSQMessagesBubbleImageFactory alloc] init] incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
    }
}

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.row];
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.row];
    if([message.senderId isEqualToString:[PFUser currentUser].objectId])
        return [JSQMessagesAvatarImage avatarWithImage:[UIImage imageNamed:@"me.jpg"]];
    else
        return [JSQMessagesAvatarImage avatarWithImage:[UIImage imageNamed:@"unknown.jpg"]];
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

//
//  ChatViewController.h
//  day6
//
//  Created by Student on 25.06.15.
//  Copyright (c) 2015 KBTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <JSQMessagesViewController/JSQMessagesViewController.h>

@interface ChatViewController : JSQMessagesViewController

@property (nonatomic) PFUser *friendUser;

@end

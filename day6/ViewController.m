//
//  ViewController.m
//  day6
//
//  Created by Student on 25.06.15.
//  Copyright (c) 2015 KBTU. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /*FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];*/
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![@"yes" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                  objectForKey:@"seen"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"seen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"first time");
        [self performSegueWithIdentifier:@"tutorialSegue" sender:self];
    }
    if([PFUser currentUser]){
        [self enterApp];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupButtonPressed:(UIButton *)sender {
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded == YES) {
            NSLog(@"Signed up");
            [self enterApp];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@",errorString);
        }
    }];
}
- (IBAction)loginWithFacebook:(UIButton *)sender {
    [PFFacebookUtils logInInBackgroundWithReadPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [self enterApp];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self enterApp];
        }
    }];
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self enterApp];
                                        } else {
                                            NSLog(@"%@",error);
                                        }
                                    }];
}

-(void)enterApp
{
    [self performSegueWithIdentifier:@"enterAppSegue" sender:self];
}

@end

//
//  TutorialViewController.m
//  day6
//
//  Created by Student on 25.06.15.
//  Copyright (c) 2015 KBTU. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.indexNumber == 0){
        self.imageView.image = [UIImage imageNamed:@"first.png"];
    }
    else if(self.indexNumber == 1){
        self.imageView.image = [UIImage imageNamed:@"second.jpg"];
    }
    else if(self.indexNumber == 2){
        self.imageView.image = [UIImage imageNamed:@"third.jpg"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

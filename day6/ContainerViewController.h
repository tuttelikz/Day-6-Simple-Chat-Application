//
//  ContainerViewController.h
//  day6
//
//  Created by Student on 26.06.15.
//  Copyright (c) 2015 KBTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;

@end

//
//  ViewController.m
//  ASAPPTestObjC
//
//  Created by Mitchell Morgan on 8/4/16.
//  Copyright © 2016 ASAPP, Inc. All rights reserved.
//

#import "ViewController.h"
//@import ASAPP;

@interface ViewController ()
//@property (nonatomic, strong) Credentials *chatCredentials;
@property (nonatomic, strong) UIButton *pushButton;
@property (nonatomic, strong) UIButton *presentButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"ASAPP Test w/ ObjC";
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.chatCredentials = [[Credentials alloc] initWithCompany:@"vs-dev"
//                                                      userToken:@"vs-cct-c6"
//                                                     isCustomer:YES
//                                            targetCustomerToken:nil];
    
    self.pushButton = [self buttonWithTitle:@"Push to Chat" action:@selector(pushToChat)];
    [self.view addSubview:self.pushButton];
    
    self.presentButton = [self buttonWithTitle:@"Present Chat" action:@selector(presentChat)];
    [self.view addSubview:self.presentButton];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:24];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat buttonMargin = 30.0f;
    CGFloat viewTop = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds) - viewTop;
    CGFloat buttonHeight = 50.0f;
    CGFloat totalButtonHeight = 2 * buttonHeight + buttonMargin;
    CGFloat buttonTop = floorf((viewHeight - totalButtonHeight) / 2.0f);
    CGFloat buttonLeft = 30.0f;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) - 2 * buttonLeft;
    
    self.pushButton.frame = CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonHeight);
    
    buttonTop = CGRectGetMaxY(self.pushButton.frame) + buttonMargin;
    self.presentButton.frame = CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonHeight);
}

#pragma mark - Actions

- (void)pushToChat
{
//    UIViewController *chatViewController = [ASAPP createChatViewControllerWithCredentials:self.chatCredentials
//                                                                                   styles:nil];
//    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)presentChat
{
//    UIViewController *chatViewController = [ASAPP createChatViewControllerWithCredentials:self.chatCredentials
//                                                                                   styles:[ASAPPStyles darkStyles]];
//    chatViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                                            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                                            target:self
//                                                            action:@selector(dismissViewControllerAnimated:completion:)];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
//    
//    [self presentViewController:navigationController animated:YES completion:nil];
}

@end

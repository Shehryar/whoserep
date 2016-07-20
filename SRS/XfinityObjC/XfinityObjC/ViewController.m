//
//  ViewController.m
//  XfinityObjC
//
//  Created by Vicky Sehrawat on 4/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

#import "ViewController.h"
#import <SRS/SRS-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Stareted");
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [SRS viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    // [SRS viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TVTroubleshootViewController.m
//  XfinityObjC
//
//  Created by Vicky Sehrawat on 4/4/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

#import "TVTroubleshootViewController.h"

@interface TVTroubleshootViewController ()

@end

@implementation TVTroubleshootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
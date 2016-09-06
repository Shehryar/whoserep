//
//  ViewController.m
//  XfinityObjC
//
//  Created by Vicky Sehrawat on 4/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

#import "ViewController.h"
#import <SRS/SRS-Swift.h>
#import "SRSProvider.h"

@interface ViewController ()

@end

@implementation ViewController

SRS *srs;
bool visible = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Stareted");
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    srs = [[SRS alloc] initWithOrigin:CGPointMake([[UIScreen mainScreen] bounds].size.width - 70, 20)
                         authProvider:^NSDictionary<NSString *,id> * {
                             return [SRSProvider getAuthToken];
                         } contextProvider:^NSDictionary<NSString *,id> * {
                             return [SRSProvider getContext];
                         } callback:^(NSString * deepLink, NSDictionary<NSString *,id> * data) {
                             [SRSProvider handleCallback:deepLink data:data];
                         }];
    [SRS viewDidAppear:true];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addSRS:) userInfo:nil repeats:false];
}

- (IBAction)toggleSRS:(id)sender {
    if (!visible) {
        //        srs = [[SRS alloc] initWithOrigin:CGPointMake([[UIScreen mainScreen] bounds].size.width - 70, 20)
        //                             authProvider:^NSDictionary<NSString *,id> * {
        //                                 return [SRSProvider getAuthToken];
        //                             } contextProvider:^NSDictionary<NSString *,id> * {
        //                                 return [SRSProvider getContext];
        //                             } callback:^(NSString * deepLink, NSDictionary<NSString *,id> * data) {
        //                                 [SRSProvider handleCallback:deepLink data:data];
        //                            }];
        [self addSRS:nil];
    } else {
        [self viewWillDisappear:true];
        //        srs = nil;
    }
}

- (void)addSRS:(NSTimer*)sender {
    [SRS viewDidAppear:true];
//    [srs setHidden:false];
    visible = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"VIEWWILLDISAPPEAR");
    [SRS viewWillDisappear:animated];
//    [srs setHidden:true];
    visible=false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

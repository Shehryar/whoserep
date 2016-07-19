//
//  SRSProvider.m
//  XfinityObjC
//
//  Created by Vicky Sehrawat on 4/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRSProvider.h"


@implementation SRSProvider

+(NSDictionary*) getContext {
    NSDictionary * context = [NSDictionary dictionaryWithObjectsAndKeys:@"something", @"some-context-here", nil];
    return context;
}

+(void)handleCallback:(NSString *)deepLink data:(NSDictionary<NSString *,id> *)data {
    NSLog(@"RETURNED LINK: %@", deepLink);
    NSLog(@"Data: %@", [data description]);
    
    UIViewController * view = nil;
    if ([deepLink isEqualToString:@"troubleshoot"]) {
        NSString* service = (NSString*)[data objectForKey:@"service"];
        if ([service isEqualToString:@"video"]) {
            view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TVTroubleshootViewController"];
        } else if ([service isEqualToString:@"internet"]) {
            view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InternetToubleshootViewController"];
        } 
    }
    
    if (view != nil) {
        UIViewController * parentView = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        UIViewController * presentedView = [parentView presentedViewController];
        if (presentedView != nil) {
            [presentedView dismissViewControllerAnimated:true completion:^{
                [parentView presentViewController:view animated:true completion:nil];
            }];
        } else {
            [parentView presentViewController:view animated:true completion:nil];
        }
    }
}

+(NSDictionary*) getAuthToken {
    NSLog(@"Requested Auth");
    NSDate * curTime = [[NSDate alloc] init];
    NSDictionary * auth = @{
        @"access_token":@"something-token-here",
        @"expires_in":@10,
        @"issued_time":curTime, // OPTIONAL
    };
    return auth;
}

@end
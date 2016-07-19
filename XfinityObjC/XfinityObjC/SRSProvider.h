//
//  SRSProvider.h
//  XfinityObjC
//
//  Created by Vicky Sehrawat on 4/4/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

#ifndef SRSProvider_h
#define SRSProvider_h

#import <UIKit/UIKit.h>

@interface SRSProvider : NSObject

+(NSDictionary*)getContext;
+(void)handleCallback:(NSString *)deepLink data:(NSDictionary<NSString *,id> *)data;
+(NSDictionary*)getAuthToken;

@end

#endif /* SRSProvider_h */

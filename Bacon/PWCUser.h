//
//  PWCUser.h
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/Facebook.h>
//#import "PWCFacebookService.h"


@interface PWCUser : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic, readonly) NSString * Id;
@property (copy, nonatomic, readonly) NSString * fullName;
@property (copy, nonatomic, readonly) NSString * gender;
@property (copy, nonatomic, readonly) NSString * email;


- (instancetype)initWithFBGraphUser;

+ (NSString *)getPathToArchive;
+ (void)saveUser:(PWCUser *)aUser;
+ (PWCUser *)getUser;

@end

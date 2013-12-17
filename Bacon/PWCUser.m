//
//  PWCUser.m
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import "PWCUser.h"

@interface PWCUser()

@property (copy, nonatomic) NSString * Id;
@property (copy, nonatomic) NSString * fullName;
@property (copy, nonatomic) NSString * gender;
@property (copy, nonatomic) NSString * email;

@end

@implementation PWCUser

- (id)init
{
    self = [self initWithFBGraphUser];
    return self;
}


- (instancetype)initWithFBGraphUser

{
    self = [super init];
    
    if (self) {
        
        //    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
        //                                    FBLoggingBehaviorFBRequests, nil]];
        
        // Fetch user data
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                           id<FBGraphUser> user,
                                           NSError *error) {
             if (!error) {
                 
                 self.Id = user.id;
                 self.fullName = user.name;
                 self.gender = user[@"gender"];
                 self.email = user[@"email"];
                 
                 NSLog(@"GraphUser %@", self.description);
        
                 [PWCUser saveUser:self];
             }
         }];
    }
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[PWCUser class] ]) return NO;
    
    PWCUser *user = (PWCUser *)object;
    
    return (self.Id == user.Id || [self.Id isEqual:user.Id])
        && (self.fullName == user.fullName || [self.fullName isEqual:user.fullName])
        && (self.gender == user.gender || [self.gender isEqual:user.gender])
        && (self.email == user.email || [self.email isEqual:user.email]);
}

- (NSUInteger)hash
{
    return self.Id.hash ^ self.fullName.hash;
}

-(NSString *)description;
{
    return [NSString
            stringWithFormat:@"[User: \n\tid: %@ \n\tname: %@ \n\tgender: %@ \n\temail: %@\n]",
            self.Id, self.fullName, self.gender, self.email];
}


#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark NSCoding

- (PWCUser *)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.Id = [aDecoder decodeObjectForKey:@"id"];
        self.fullName = [aDecoder decodeObjectForKey:@"name"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Id forKey:@"id"];
    [aCoder encodeObject:self.fullName forKey:@"name"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.email forKey:@"email"];
}

+ (NSString *)getPathToArchive
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                            NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    
    return [docsDir stringByAppendingPathComponent:@"user.model"];
}


+ (void)saveUser:(PWCUser *)aUser
{
    [NSKeyedArchiver archiveRootObject:aUser
                                toFile:[PWCUser getPathToArchive]];
}


+ (PWCUser *)getUser
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[PWCUser getPathToArchive]];
}



@end

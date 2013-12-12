//
//  PWCUser.m
//  Bacon
//
//  Created by Ravi on 11/12/2013.
//  Copyright (c) 2013 PWC. All rights reserved.
//

#import "PWCUser.h"

@implementation PWCUser

- (id)init
{
    self = [self initWithFBGraphUser];
    return self;
}


- (id)initWithFBGraphUser

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

-(NSString *)description;
{
    return [NSString
            stringWithFormat:@"[User: \n\tid: %@ \n\tname: %@ \n\tgender: %@ \n\temail: %@\n]",
            self.Id, self.fullName, self.gender, self.email];
}

@end

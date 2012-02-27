//
//  OperationNecessaryToApprove.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "OperationNecessaryToApprove.h"
#import "CurrentCompany.h"


@implementation OperationNecessaryToApprove

@dynamic changingAttributeName;
@dynamic creationDate;
@dynamic desc;
@dynamic forEntity;
@dynamic forGUID;
@dynamic GUID;
@dynamic modificationDate;
@dynamic operation;
@dynamic currentCompany;
- (void)awakeFromInsert {
    NSDate *now = [NSDate date];
    
    [self willChangeValueForKey:@"GUID"];
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"GUID"];
    [self didChangeValueForKey:@"GUID"];
    
    [self willChangeValueForKey:@"creationDate"];
    [self setPrimitiveValue:now forKey:@"creationDate"];
    [self didChangeValueForKey:@"creationDate"];
    
    [self willChangeValueForKey:@"modificationDate"];
    [self setPrimitiveValue:now forKey:@"modificationDate"];
    [self didChangeValueForKey:@"modificationDate"];
}

-(void)willSave {
    NSDate *now = [NSDate date];
    if ([self isUpdated]) {
        
        
        if (self.modificationDate == nil || [now timeIntervalSinceDate:self.modificationDate] > 1.0) {
            self.modificationDate = now;
        }
    }
}

@end

//
//  OperationNecessaryToApprove.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrentCompany;

@interface OperationNecessaryToApprove : NSManagedObject

@property (nonatomic, retain) NSString * changingAttributeName;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * forEntity;
@property (nonatomic, retain) NSString * forGUID;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * operation;
@property (nonatomic, retain) CurrentCompany *currentCompany;

@end

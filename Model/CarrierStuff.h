//
//  CarrierStuff.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier;

@interface CarrierStuff : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * emailList;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * msn;
@property (nonatomic, retain) NSString * otherIMs;
@property (nonatomic, retain) NSString * phoneList;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * skype;
@property (nonatomic, retain) Carrier *carrier;

@end

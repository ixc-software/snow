//
//  Events.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MainSystem;

@interface Events : NSManagedObject

@property (nonatomic, retain) NSNumber * addedToCalendar;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateAlarm;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id nameData;
@property (nonatomic, retain) NSString * necessaryData;
@property (nonatomic, retain) NSNumber * resolved;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) MainSystem *mainSystem;

@end

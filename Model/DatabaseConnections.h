//
//  DatabaseConnections.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CurrentCompany;

@interface DatabaseConnections : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * database;
@property (nonatomic, retain) id directions;
@property (nonatomic, retain) NSNumber * enable;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSNumber * selectionDirections;
@property (nonatomic, retain) NSNumber * selectionUpdateChoices;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) id updateChoices;
@property (nonatomic, retain) NSString * urlForRouting;
@property (nonatomic, retain) CurrentCompany *currentCompany;

@end

//
//  LinkedinUpdateDataController.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/5/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#include <libxml/xmlreader.h>

@interface LinkedinUpdateDataController : NSObject { 
@private
    OAToken *accessToken;
    OAConsumer *consumer;

    id delegate;
    BOOL isAuthorized;
    NSString *linkedinPIN;
    
    NSData *rdXML;
	xmlTextReaderPtr rdReader;
    id rdResults;
    NSError* rdError;

    BOOL isLatesGroupsGetAttempt;
}

@property (nonatomic,assign) id delegate;
@property (nonatomic,retain) OAToken *accessToken;
@property (nonatomic,retain) OAConsumer *consumer;


@property (readwrite) BOOL isAuthorized;
@property (nonatomic,retain) NSString *linkedinPIN;

- (IBAction)startAuthorization:(id)sender;
- (IBAction)finishAuthorization:(id)sender withUrl:(NSURL *)url; 

- (id)initWithDelegate:(id)delegateForInit;
-(void) getGroupsStart:(NSUInteger)startPosition count:(NSUInteger)count;

@end

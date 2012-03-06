//
//  LinkedinUpdateDataController.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/5/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"

@interface LinkedinUpdateDataController : NSObject { 
@private
    OAToken *accessToken;
    id delegate;
    BOOL isAuthorized;
    NSString *linkedinPIN;

}

@property (nonatomic,assign) id delegate;
@property (nonatomic,assign) OAToken *accessToken;

@property (readwrite) BOOL isAuthorized;
@property (nonatomic,retain) NSString *linkedinPIN;

- (IBAction)startAuthorization:(id)sender;
- (IBAction)finishAuthorization:(id)sender withUrl:(NSURL *)url; 

- (id)initWithDelegate:(id)delegateForInit;

@end

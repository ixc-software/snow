//
//  LinkedinUpdateDataController.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/5/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "LinkedinUpdateDataController.h"
#import "JSONKit.h"

#define kOAuthConsumerKey				@"h3i1eddlw1jx"		
#define kOAuthConsumerSecret			@"qa7Mao7H9NOOoeCm"		

@implementation LinkedinUpdateDataController
@synthesize delegate,isAuthorized,linkedinPIN,accessToken,consumer;

- (id)initWithDelegate:(id)delegateForInit;
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.delegate = delegateForInit;
    }
    
    return self;

}

#pragma mark -
#pragma mark request token block (lindkedin methods)


- (IBAction) getRequestToken:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if (!consumer) self.consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
                                                        secret:kOAuthConsumerSecret
                                                         realm:@"http://api.linkedin.com/"];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        
        NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/requestToken"];
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                       consumer:consumer
                                                                          token:nil
                                                                       callback:@"hdlinked://linkedin/oauth"
                                                              signatureProvider:nil];
        
        [request setHTTPMethod:@"POST"];
        
        NSLog(@"Getting request token...");
        
        [fetcher fetchDataWithRequest:request 
                             delegate:self
                    didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                      didFailSelector:@selector(requestTokenTicket:didFailWithError:)];	
        [consumer release];
    });
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data 
													   encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        //accessToken.verifier =  @"hdlinked://linkedin/oauth";

        [responseBody release];
		
		
		NSString *address = [NSString stringWithFormat:
							 @"https://www.linkedin.com/uas/oauth/authorize?oauth_token=%@",
							 accessToken.key];

        NSLog(@"Got request token. Redirecting to linkedin auth page:%@",address);

		NSURL *url = [NSURL URLWithString:address];
        
        // delegate open panel for autorization and input pin (don't forget set pin property!!!)
        if (delegate != nil && [delegate respondsToSelector:@selector(linkedinAuthForURL:)]) {
            [delegate performSelector:@selector(linkedinAuthForURL:) withObject:url];
        }
        
	}
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Getting request token failed: %@", [error localizedDescription]);
    if (delegate != nil && [delegate respondsToSelector:@selector(linkedinAuthFailed)]) {
        [delegate performSelector:@selector(linkedinAuthFailed)];
    }

}

#pragma mark -
#pragma mark access token block (linkedin methods)


- (IBAction) getAccessToken:(id)sender withURL:(NSURL *)url
{
    if (!consumer) self.consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
                                                    secret:kOAuthConsumerSecret
                                                     realm:@"http://api.linkedin.com/"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	NSURL *urlToken = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/accessToken"];
    OAToken *accessTokenLocal = accessToken;
    
	[accessTokenLocal setVerifierWithUrl:url];
	
    NSLog(@"Using PIN %@", [accessTokenLocal verifier]);
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:urlToken
																   consumer:consumer
																	  token:accessTokenLocal
																	  callback:nil
														  signatureProvider:nil];
	
	[request setHTTPMethod:@"POST"];
    
    NSLog(@"Getting access token...");
	
	[fetcher fetchDataWithRequest:request 
						 delegate:self
				didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
	[request release];
    
    
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [responseBody release];
        
		NSLog(@"Got access token. Ready to use Linkedin API.");
        isAuthorized = YES;
        if (delegate != nil && [delegate respondsToSelector:@selector(linkedinAuthSuccess)]) {
            [delegate performSelector:@selector(linkedinAuthSuccess)];
        }
        
	}
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting access token failed: %@", [error localizedDescription]);
    if (delegate != nil && [delegate respondsToSelector:@selector(linkedinAuthFailed)]) {
        [delegate performSelector:@selector(linkedinAuthFailed)];
    }
    
}

#pragma mark -
#pragma mark twitter  authorization flow

// authorize login/pass
- (IBAction)startAuthorization:(id)sender ;
{
    [self getRequestToken:sender];
}
// put inserted pin and authozied final
- (IBAction)finishAuthorization:(id)sender withUrl:(NSURL *)url; 
{
    [self getAccessToken:sender withURL:url];
}
#pragma mark -
#pragma mark xml parser methods
- (BOOL)nextNode {
    if( rdError ) return NO;
    
    int result = xmlTextReaderRead(rdReader);
    
    if( result == -1 ) {
        xmlErrorPtr err = xmlGetLastError();
        if( err ) {
            NSLog(@"libxml error level %i: %s", err->level, err->message);
            // TODO: set rdError properly
        }
        else {
        }
    }
    
    return result == 1;
}

- (BOOL)parseInternal {
    NSMutableArray* elementStack = [[NSMutableArray alloc] init];
    NSMutableDictionary* element = nil;
    
    while( [self nextNode] ) {
        int nodeType = xmlTextReaderNodeType(rdReader);
        int depth = xmlTextReaderDepth(rdReader);
        const xmlChar *name = xmlTextReaderConstName(rdReader);
        //NSLog(@"read node type %2i at depth %3i: %s", nodeType, depth, name);
        
        NSMutableString* text = nil;
        NSMutableDictionary* child = nil;
        NSString* key;
        id currentValue = nil;
        id newValue = nil;
        
        switch( nodeType ) {
            case XML_READER_TYPE_ELEMENT:
                element = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithUTF8String:(const char *)name], @"#name",
                           [NSMutableString string], @"#text",
                           nil];
                [elementStack addObject:element];
                break;
                
            case XML_READER_TYPE_TEXT:
                text = [element objectForKey:@"#text"];
                [text appendString:[NSMutableString stringWithUTF8String:(const char *)xmlTextReaderValue(rdReader)]];
                break;
                
            case XML_READER_TYPE_END_ELEMENT:
                child = [element retain];
                [elementStack removeLastObject];
                //NSLog(@"popped node %@", child);
                
                key = [[child objectForKey:@"#name"] retain];
                text = [element objectForKey:@"#text"];
                [child removeObjectForKey:@"#name"];
                
                if( [elementStack count] ) {
                    element = [elementStack lastObject];
                    currentValue = [element objectForKey:key];
                    
                    if( [child count] == 1 ) {
                        // new node has only text, no children
                        newValue = text;
                    }
                    else {
                        newValue = child;
                        if( [text length] == 0 ) [child removeObjectForKey:@"#text"];
                    }
                    
                    if( !currentValue ) {
                        [element setObject:newValue forKey:key];
                    }
                    else if( [currentValue isKindOfClass:[NSMutableArray class]] ) {
                        [currentValue addObject:newValue];
                    }
                    else {
                        currentValue = [NSMutableArray arrayWithObjects:currentValue, newValue, nil];
                        [element setObject:currentValue forKey:key];
                    }
                }
                else {
                    // if the stack emptied before we got back to the root node, that's an error
                    // a non-null error pointer will cause the parsing loop to abort on the next pass
                    if( depth != 0 ) {
                        rdError = [NSError errorWithDomain:@"snow"
                                                      code:1
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [NSString stringWithUTF8String:(const char *)name], @"currentElement",
                                                            [NSNumber numberWithInt:depth], @"depth",
                                                            nil]];
                    }
                    else {
                        if( [text length] == 0 ) [child removeObjectForKey:@"#text"];
                        rdResults = [child retain];
                    }
                }
                [child release];
                [key release];
                break;
        }
    }
    
    [elementStack release];
    return !rdError;
}

-(id) parseXMLForData:(NSData *)data withURL:(NSURL *)url;
{
    BOOL success = YES;

    rdXML = [data retain];
    //rdReader = xmlReaderForMemory([rdXML bytes], [rdXML length], [[url absoluteString] UTF8String], nil, XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
    if( ! rdReader ) {
        NSLog(@"LINKEDIN CONTROLLER: reader not started");
        return nil;

    }
    if( !(success = [self parseInternal]) ) {
        NSLog(@"LINKEDIN CONTROLLER: parser error");
        return nil;

    }
    //if( !rdReader && rdResults ) {
      //  NSLog(@"LINKEDIN CONTROLLER: parse results:%@",rdResults);
    //}

    xmlFree(rdReader);

    return rdResults;
}


#pragma mark -
#pragma mark linkedin main methods

-(void) getGroupsStart:(NSUInteger)startPosition count:(NSUInteger)count;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/group-memberships:(group:(id,name))?count=10&start=%@&format=json",[NSNumber numberWithUnsignedInteger:startPosition]]];
        //NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
        NSLog(@"LINKEDIN GET GROUPS:get  URL:%@",url);

        OAMutableURLRequest *request = 
        [[OAMutableURLRequest alloc] initWithURL:url
                                        consumer:consumer
                                           token:accessToken
                                        callback:nil
                               signatureProvider:nil];
        [request setHTTPMethod:@"GET"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:request
                             delegate:self
                    didFinishSelector:@selector(getGroupsResult:didFinish:)
                      didFailSelector:@selector(getGroupsResult:didFail:)];    
        [request release];
    });
    
}
- (void)getGroupsResult:(OAServiceTicket *)ticket didFinish:(NSData *)data;
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/group-memberships"]];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/group-memberships:(group:(id,name,counts-by-category))?membership-state=member&format=json"]];

    //NSLog(@"LINKEDIN CONTROLLER: parse results:%@",[self parseXMLForData:data withURL:url]);
    NSDictionary *result = [responseBody objectFromJSONString];
    //NSLog(@"LINKEDIN GET GROUPS:get  SUCCESS parsed result:%@",result);

    if (delegate != nil && [delegate respondsToSelector:@selector(twitterAuthFailed)]) {
        //id result = [self parseXMLForData:data withURL:url];
        //NSLog(@"LINKEDIN GET GROUPS:get  SUCCESS parsed result:%@",result);

        if (isLatesGroupsGetAttempt) { 
            [delegate performSelector:@selector(linkedinGroupsList:withLatestGroups:) withObject:result withObject:[NSNumber numberWithBool:YES]];

            isLatesGroupsGetAttempt = NO;
            return;
        } else [delegate performSelector:@selector(linkedinGroupsList:withLatestGroups:) withObject:result withObject:[NSNumber numberWithBool:NO]];

    }
    //NSNumber *count = [result valueForKey:@"_count"];
    NSNumber *start = [result valueForKey:@"_start"];
    NSNumber *total = [result valueForKey:@"_total"];
    start = [NSNumber numberWithUnsignedInteger:start.unsignedIntegerValue + 10];
    if (start.unsignedIntegerValue > total.unsignedIntegerValue) {
        // this is last attempt
        isLatesGroupsGetAttempt = YES;
        [self getGroupsStart:start.unsignedIntegerValue count:total.unsignedIntegerValue - start.unsignedIntegerValue];

    } else {
        [self getGroupsStart:start.unsignedIntegerValue count:10];
    }

}



- (void)getGroupsResult:(OAServiceTicket *)ticket didFail:(NSData *)data 
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    //NSDictionary *result = [responseBody objectFromJSONString];
    NSLog(@"LINKEDIN GET GROUPS:get  FAILED result:%@",responseBody);
    
}

-(void) postToGroupID:(NSString *)groupID withTitle:(NSString *)title withSummary:(NSString *)summary;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.linkedin.com/v1/groups/%@/posts",groupID]];
        NSLog(@"LINKEDIN POST TO GROUPS:get  URL:%@",url);
        
        OAMutableURLRequest *request = 
        [[OAMutableURLRequest alloc] initWithURL:url
                                        consumer:consumer
                                           token:accessToken
                                        callback:nil
                               signatureProvider:nil];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        
        NSString *finalBody = [NSString stringWithFormat:@"<post> <title>%@</title> <summary>%@</summary></post>",title,summary];
        NSData* body = [finalBody dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:request
                             delegate:self
                    didFinishSelector:@selector(postToGroupResult:didFinish:)
                      didFailSelector:@selector(postToGroupResult:didFail:)];    
        [request release];
    });

}
- (void)postToGroupResult:(OAServiceTicket *)ticket didFinish:(NSData *)data;
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    //NSDictionary *result = [responseBody objectFromJSONString];
    NSLog(@"LINKEDIN POST TO GROUPS:POST result:%@",responseBody);
}

- (void)postToGroupResult:(OAServiceTicket *)ticket didFail:(NSData *)data 
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    //NSDictionary *result = [responseBody objectFromJSONString];
    NSLog(@"LINKEDIN GET GROUPS:POST FAILED result:%@",responseBody);
    
}

@end

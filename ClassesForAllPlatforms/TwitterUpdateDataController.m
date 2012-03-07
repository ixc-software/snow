//
//  TwitterUpdateController.m
//  snow
//
//  Created by Oleksii Vynogradov on 24.08.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//
#import "OAuthConsumer.h"
//#import "MGTwitterEngine.h"
#import "JSONKit.h"

#import "TwitterUpdateDataController.h"

#define kOAuthConsumerKey				@"VUY8coMFF42XqEP2gQU5A"		//REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret			@"tPeDllo8tHWy2ccTCpbcuruXbSkw32VZz4Bs2vGA"		//REPLACE With 


@implementation TwitterUpdateDataController

@synthesize delegate,twitterPIN,isAuthorized;//,consumer,accessToken;


- (id)init
{
    self = [super init];
    if (self) {
        isAuthorized = NO;
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDelegate:(id)delegateForInit;
{
    self = [super init];
    if (self) {
        isAuthorized = NO;
        // Initialization code here.
        self.delegate = delegateForInit;
    }
    
    return self;

}


- (void)dealloc
{
    [accessToken release];
    [consumer release];
    [delegate release];
    [super dealloc];
}

#pragma mark -
#pragma mark request token block (twitter methods)


- (IBAction) getRequestToken:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if (!consumer) consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
                                                           secret:kOAuthConsumerSecret 
                                                            realm:nil];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                       consumer:consumer
                                                                          token:nil
                                                                       callback:nil
                                                              signatureProvider:nil];
        
        [request setHTTPMethod:@"POST"];
        
        //NSLog(@"Getting request token...");
        
        [fetcher fetchDataWithRequest:request 
                             delegate:self
                    didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                      didFailSelector:@selector(requestTokenTicket:didFailWithError:)];	
    });
    //    [consumer release];
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data 
													   encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [responseBody release];
		
		NSLog(@"Got request token:%@. Redirecting to twitter auth page...",accessToken);
		
		NSString *address = [NSString stringWithFormat:
							 @"https://api.twitter.com/oauth/authorize?oauth_token=%@",
							 accessToken.key];
		
		NSURL *url = [NSURL URLWithString:address];
    
        // delegate open panel for autorization and input pin (don't forget set pin property!!!)
        if (delegate != nil && [delegate respondsToSelector:@selector(startTwitterAuthForURL:)]) {
            [delegate performSelector:@selector(startTwitterAuthForURL:) withObject:url];
        }

	}
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Getting request token failed: %@", [error localizedDescription]);
    if (delegate != nil && [delegate respondsToSelector:@selector(twitterAuthFailed)]) {
        [delegate performSelector:@selector(twitterAuthFailed)];
    }

}


#pragma mark -
#pragma mark access token block (twitter methods)


- (IBAction) getAccessToken:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if (!consumer) consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
                                                           secret:kOAuthConsumerSecret 
                                                            realm:nil];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
        //OAToken *accessTokenLocal = accessToken;
        
        [accessToken setVerifier:twitterPIN];
        
        NSLog(@"Using PIN %@", [accessToken verifier]);
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                       consumer:consumer
                                                                          token:accessToken
                                                                       callback:nil
                                                              signatureProvider:nil];
        //[consumer release];
        
        [request setHTTPMethod:@"POST"];
        
        
        NSLog(@"Getting access token...");
        
        [fetcher fetchDataWithRequest:request 
                             delegate:self
                    didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                      didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
        [request release];
    });
    
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        //        NSError *error = nil;
        //        NSDictionary *finalResult = [jkitDecoder objectWithUTF8String:(const unsigned char *)[responseBody UTF8String] length:[responseBody length] error:&error];
        //        NSString *oauthToken = [finalResult valueForKey:@"oauth_token"];
        //        NSString *oauthTokenSecret = [finalResult valueForKey:@"oauth_token_secret"];
        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
		NSLog(@"Got access token:%@. Ready to use Twitter API.",responseBody);
        [responseBody release];
        
        isAuthorized = YES;
        if (delegate != nil && [delegate respondsToSelector:@selector(twitterAuthSuccess)]) {
            [delegate performSelector:@selector(twitterAuthSuccess)];
        }
       
	}
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting access token failed: %@", [error localizedDescription]);
    if (delegate != nil && [delegate respondsToSelector:@selector(twitterAuthFailed)]) {
        [delegate performSelector:@selector(twitterAuthFailed)];
    }
    
}

#pragma mark -
#pragma mark working with data (twitter methods)


//- (void) refreshTweets {
//    [twitterEngine getHomeTimelineSinceID:0 startingAtPage:0 count:20];
//}
//


-(void) postTwitterMessageWithText:(NSString *)text;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSString *status = [text precomposedStringWithCanonicalMapping];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/statuses/update.json"]];
        //NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
        OAMutableURLRequest *request = 
        [[OAMutableURLRequest alloc] initWithURL:url
                                        consumer:consumer
                                           token:accessToken
                                        callback:nil
                               signatureProvider:nil];
        [request setHTTPMethod:@"POST"];
        
        OARequestParameter *x1 = [[OARequestParameter alloc] initWithName:@"status" value:status];
        
        NSArray *params = [NSArray arrayWithObjects:x1, nil];
        [request setParameters:params];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:request
                             delegate:self
                    didFinishSelector:@selector(postTwitterMessageResult:didFinish:)
                      didFailSelector:@selector(postTwitterMessageResult:didFail:)];    
        [request release];
    });
}
- (void)postTwitterMessageResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *result = [responseBody objectFromJSONString];
    NSLog(@"TWITTER UPDATE:post twitter SUCCESS result:%@",result);
}

- (void)postTwitterMessageResult:(OAServiceTicket *)ticket didFail:(NSData *)data 
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *result = [responseBody objectFromJSONString];
    NSLog(@"TWITTER UPDATE:post twitter FAILED result:%@",result);

}

-(void) postTwitterMessageForDestinations:(NSArray *)destinations;
{
    //NSMutableString *twitterText = [[NSMutableString alloc] initWithCapacity:0];
    NSString *intro = @"I'm currently interesting for those destination (s):";

    NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
    [rateFormatter setMaximumFractionDigits:5];
    [rateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //[destinations enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *object, NSUInteger idx, BOOL *stop) {
        for (NSDictionary *object in destinations) {
        NSString *country = [object valueForKey:@"country"];
        NSString *specific = [object valueForKey:@"specific"];
        NSNumber *rate = [object valueForKey:@"rate"];
        NSNumber *minutesLenght = [object valueForKey:@"minutesLenght"];
        

        //[twitterText appendString:intro];
            NSString *twitterText = [NSString stringWithFormat:@"%@ %@/%@ with price %@ volume %@ (posted from snow ixc) ",intro,country,specific,[rateFormatter stringFromNumber:rate],minutesLenght];
        
        [self postTwitterMessageWithText:twitterText];

        }
    //}];
    //[self postTwitterMessageWithText:twitterText];
    

    [rateFormatter release];

}

//#pragma mark -
//#pragma mark apiTicket block (twitter methods)
//
//
//- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
//{
//	if (ticket.didSucceed)
//	{
//		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"Got home timeline. Length: %@.", [NSNumber numberWithUnsignedInteger:[responseBody length]]);
//            NSLog(@"Body:\n%@", responseBody);
//        [responseBody release];
//        
//	}
//}
//
//- (void) apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
//{
//	NSLog(@"Getting home timeline failed: %@", [error localizedDescription]);
//}

#pragma mark -
#pragma mark twitter  authorization flow

// authorize login/pass
- (IBAction)startAuthorization:(id)sender ;
{
    [self getRequestToken:sender];
}
// put inserted pin and authozied final
- (IBAction)finishAuthorization:(id)sender; 
{
    [self getAccessToken:sender];
}

@end

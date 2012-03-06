//
//  LinkedinUpdateDataController.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/5/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "LinkedinUpdateDataController.h"

#define kOAuthConsumerKey				@"h3i1eddlw1jx"		
#define kOAuthConsumerSecret			@"qa7Mao7H9NOOoeCm"		

@implementation LinkedinUpdateDataController
@synthesize delegate,isAuthorized,linkedinPIN,accessToken;

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
#pragma mark request token block (twitter methods)


- (IBAction) getRequestToken:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
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
        if (delegate != nil && [delegate respondsToSelector:@selector(startTwitterAuthForURL:)]) {
            [delegate performSelector:@selector(startTwitterAuthForURL:) withObject:url];
        }
        
	}
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Getting request token failed: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark access token block (twitter methods)


- (IBAction) getAccessToken:(id)sender withURL:(NSURL *)url
{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey
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
    [consumer release];
    
    
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

@end

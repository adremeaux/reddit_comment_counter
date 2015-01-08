//
//  AppDelegate.m
//  CommentCounter
//
//  Created by Andy Dremeaux on 1/7/15.
//  Copyright (c) 2015 Andy Dremeaux. All rights reserved.
//

#import "AppDelegate.h"

NSString *const baseURL = @"http://www.reddit.com/user/adremeaux/comments/.json?count=25";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property NSUInteger count;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.count = 0;
	[self performRequest:nil];
}

- (void)performRequest:(NSString *)after {
	NSURL *url;
	if (after)
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&after=%@", baseURL, after]];
	else
		url = [NSURL URLWithString:baseURL];
	
	
	[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0]
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   
							   if (error) {
								   NSLog(@"load error: %@", error);
								   return;
							   }
							   
							   NSString *rawConfigData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
							   
							   NSDictionary *dict = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:[rawConfigData dataUsingEncoding:NSUTF8StringEncoding]
																									 options:NSJSONReadingMutableContainers
																									   error:&error];
							   if (dict == nil) {
								   NSLog(@"error parsing JSON");
								   return;
							   }
							   
							   NSUInteger newCount = ((NSArray *)dict[@"data"][@"children"]).count;
							   self.count += newCount;
							   
							   if (newCount < 25) {
								   NSLog(@"done! total comments: %lu", (unsigned long)self.count);
								   return;
							   }
							   
							   NSString *newAfter = dict[@"data"][@"after"];
							   
							   if (!newAfter) {
								   NSLog(@"done? total comments: %lu", (unsigned long)self.count);
							   }
							   
							   NSLog(@"%@ - count: %lu", newAfter, (unsigned long)self.count);
							   
							   [self performRequest:newAfter];
						   }];
}







- (void)applicationWillTerminate:(NSNotification *)aNotification {
	
}

@end

//
//  MDURLConnection.h
//  Mingdao
//
//  Created by Wee Tom on 13-4-26.
//
//

#import <Foundation/Foundation.h>

extern NSString *MDURLConnectionIPErrorOccurred;

typedef void (^MDAPINSDataHandler)(NSData *data, NSError *error);
typedef void (^MDAPICGFloatHandler)(float fValue);

@interface MDURLConnection : NSObject
- (MDURLConnection *)initWithRequest:(NSURLRequest *)request handler:(MDAPINSDataHandler)handler;
@property (readonly, nonatomic) NSURLRequest *request;
@property (assign, nonatomic) NSTimeInterval timeOut;
@property (copy, nonatomic) MDAPICGFloatHandler downloadProgressHandler, uploadProgressHandler;
- (void)start;
- (void)cancel;
@end

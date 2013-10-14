//
//  QSocket.h
//  NetBaduk
//
//  Created by 엔비 on 09. 10. 10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netdb.h>

#define QSOCKET			[QSocket sharedMgr]

@protocol QSocketReceiver <NSObject>
- (void)onConnect:(bool)connect;
- (void)onWriteable;
- (void)onRecv:(char *)data Len:(int)len;
- (void)onError:(NSString *)errorMsg;
@end

@interface QSocket : NSObject
{
	int _socketId;
	CFSocketRef _socketRef;
	id<QSocketReceiver> _receiver;
	
	char _recvPool[1024], *_packetPool[16];
	int _recvSize, _packetCnt;
}

+ (QSocket *)sharedMgr;
- (id)initWithServerAddr:(char *)addr Port:(unsigned short)port Receiver:(id<QSocketReceiver>)receiver;

- (void)send:(const char *)data Len:(int)len;

- (void)onConnect:(bool)connect;
- (void)onWriteable;
- (void)onRecv:(char *)data Len:(int)len;
- (void)onError:(NSString *)errorMsg;

@end


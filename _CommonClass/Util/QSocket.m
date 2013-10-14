//
//  QSocket.m
//  NetBaduk
//
//  Created by 엔비 on 09. 10. 10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QSocket.h"

void CFSockCallBack(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    if(callbackType == kCFSocketDataCallBack)
	{
		const UInt8 *buf = CFDataGetBytePtr((CFDataRef)data);
		int len = CFDataGetLength((CFDataRef)data);
		[QSOCKET onRecv:(char *)buf Len:len];
	}
	if(callbackType == kCFSocketWriteCallBack)
	{
		[QSOCKET onWriteable];
	}
	if(callbackType == kCFSocketConnectCallBack)
	{
		[QSOCKET onConnect:data == NULL];
	}
}

@implementation QSocket

static QSocket *_sharedMgr = nil;

+ (QSocket *)sharedMgr
{
	@synchronized(self)
	{
		if(_sharedMgr == nil) _sharedMgr = [QSocket alloc];
		return _sharedMgr;
	}
	
	return nil;
}

- (id)initWithServerAddr:(char *)addr Port:(unsigned short)port Receiver:(id<QSocketReceiver>)receiver
{
	[super init];
	
	_receiver = receiver;
	_socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, 0, kCFSocketDataCallBack|kCFSocketConnectCallBack|kCFSocketWriteCallBack, CFSockCallBack, NULL);
	_socketId = CFSocketGetNative(_socketRef);
	
	struct sockaddr_in serverAddr;
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(port);
    
	struct hostent *hp = gethostbyname(addr);
	if(hp == NULL)
	{
		NSLog(@"error getting host address");
		[QSOCKET onError:@"error getting host address"];
	}
	else
	{
		// 접속 주소 데이터를 만들어서 서버에 연결
		memcpy(&serverAddr.sin_addr.s_addr, hp->h_addr_list[0], hp->h_length);
		CFDataRef addressData = CFDataCreate(NULL, (UInt8 *)&serverAddr, sizeof(struct sockaddr_in));
		CFSocketConnectToAddress(_socketRef, addressData, -1);
		
		// 소켓에 대한 LoopSource 를 만들고 이 LoopSource 를 실행
		CFRunLoopSourceRef FrameRunLoopSource = CFSocketCreateRunLoopSource(NULL, _socketRef , 0);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), FrameRunLoopSource, kCFRunLoopCommonModes); 
	}
	
	return self;
}

- (void)send:(const char *)data Len:(int)len
{
//	write(_socketId, data, len);
}


- (void)onConnect:(bool)connect
{
	if(_receiver != nil) [_receiver onConnect:connect];
}

- (void)onWriteable
{
	if(_receiver != nil) [_receiver onWriteable];
}

/*- (void)onRecv:(char *)data Len:(int)len
{
	memcpy(_recvPool + _recvSize, data, len);
	_recvSize += len;
//	if(_receiver != nil) [_receiver onRecv:data Len:len];
	for(int i = 0; i < _recvSize; i++)
	{
		if(*(unsigned short *)(_recvPool + i) == *(unsigned short *)"\r\n")
		{
			[_receiver onRecv:_recvPool Len:i];
			_recvSize -= i + 2;
			memmove(_recvPool, _recvPool + i + 2, _recvSize);
			i = 0;
		}
	}
}*/

- (void)onRecv:(char *)data Len:(int)len
{
	memcpy(_recvPool + _recvSize, data, len);
	_recvSize += len;
	
	unsigned short packSize = *(unsigned short *)_recvPool;
	while(packSize > 0 && _recvSize >= packSize)
	{
		[_receiver onRecv:_recvPool + 2 Len:packSize - 2];
		_recvSize -= packSize;
		if(_recvSize > 2)
		{
			memmove(_recvPool, _recvPool + packSize, _recvSize);
			packSize = *(unsigned short *)_recvPool;
		}
		else
		{
			packSize = 0;
		}
	}
}

- (void)onError:(NSString *)errorMsg
{
	if(_receiver != nil) [_receiver onError:errorMsg];
}

@end

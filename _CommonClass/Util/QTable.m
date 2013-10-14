//
//  TableData.m
//  iRev
//
//  Created by 엔비 on 09. 03. 29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QTable.h"


@implementation QTable

@synthesize row=_lineCount, column=_columnCount;

- (void)decodeFile
{
	char *buffer;
	NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fortunes" ofType:@"qus"]];
	int len = [data length];
	buffer = malloc(len);
	[data getBytes:buffer length:len];
	
	char key = 'Q', tmpKey;
	for(int i = 0; i < len; i++)
	{
		tmpKey = buffer[i];
		buffer[i] ^= key;
		key ^= tmpKey;
	}
	
	char *token = NULL;
	token = strtok(buffer, "\r\n\0");
	while(token)
	{
//		NSString *string = [NSString stringWithUTF8String:token];
//		[_fortuneArray addObject:string];
		
		token = strtok(NULL, "\r\n\0");
	}
	
	free(buffer);
}

- (id)initWithFile:(NSString *)fileName
{
	[super init];
	
	NSData *data = [[NSData alloc] initWithContentsOfFile:fileName];
	int len = [data length];
	char *buffer = malloc(len + 1);
	char *ptr = buffer;
	[data getBytes:buffer length:len];
	
	if(strncmp(buffer, "EncTbl", 6) == 0)
	{
		srandom(731127);
		for(int i = 6; i < len; i++) buffer[i] ^= (random() % 227);
		ptr += 6;
		len -= 6;
	}
	
	ptr[len] = 0;

	[self loadBuffer:ptr];

	free(buffer);
	[data release];
	return self;
}

- (BOOL)loadBuffer:(char *)buffer
{
	char *szLine;
	char szData[1024];

	szLine = strtok(buffer, "\r\n\0");
	if(szLine)		// 첫번째 라인에서 키값들을 읽어온다.
	{
		_dictData = [[NSMutableDictionary alloc] init];
		_dictKey = [[NSMutableArray alloc] init];
		
		int start = 0, pos = 0;
		do
		{
			start = pos;
			pos = [self getDataFrom:szLine Pos:start To:szData];
			if(start != pos)
			{
				while(strlen(szData) > 0 && szData[strlen(szData)-1] == ' ') szData[strlen(szData)-1] = 0;
				[_dictKey addObject:[[NSString alloc] initWithUTF8String:szData]];
			}
		} while(pos != start);
		
		_columnCount = _dictKey.count;
	}
	else
	{
		return NO;
	}
	
	_lineCount = 0;
	szLine = strtok(NULL, "\r\n\0");
	while(szLine)
	{
		if(strlen(szLine) > 0 && strncmp(szLine, "//", 2) != 0)
		{
			int start = 0, pos = 0, col = 0;
			do
			{
				start = pos;
				pos = [self getDataFrom:szLine Pos:start To:szData];
				while(strlen(szData) > 0 && szData[strlen(szData)-1] == ' ') szData[strlen(szData)-1] = 0;
				if(col < [_dictKey count])
				{
					NSString *data = [[NSString alloc] initWithUTF8String:szData];
					NSString *key = [[NSString alloc] initWithFormat:@"%d@%@", _lineCount, [_dictKey objectAtIndex:col]];
					[_dictData setObject:data forKey:key];
					[data release];
					[key release];
				}
				col++;
			} while(pos != start && col < [_dictKey count]);
			_lineCount++;
		}
		
		szLine = strtok(NULL, "\r\n\0");
	}
	
	return YES;
}

/*- (id)initWithFile:(NSString *)fileName
{
	[super init];

//	char *token;
	char szData[256];
	char szLine[1024];
	FILE *fp = fopen([fileName UTF8String], "rt");
	if(fp == NULL) return self;
	
	if(fgets(szLine, 1024, fp))		// 첫번째 라인에서 키값들을 읽어온다.
	{
		_dictData = [[NSMutableDictionary alloc] init];
		_dictKey = [[NSMutableArray alloc] init];
		
		int start = 0, pos = 0;
		do
		{
			start = pos;
			pos = [self getDataFrom:szLine Pos:start To:szData];
			while(strlen(szData) > 0 && szData[strlen(szData)-1] == ' ') szData[strlen(szData)-1] = 0;
			[_dictKey addObject:[[NSString alloc] initWithUTF8String:szData]];
		} while(pos != start);

		_columnCount = _dictKey.count;
	}
	else
	{
		fclose(fp);
		return self;
	}
	
	_lineCount = 0;
	while(fgets(szLine, 1024, fp))
	{
		if(strlen(szLine) > 0 && strncmp(szLine, "//", 2) != 0)
		{
			int start = 0, pos = 0, col = 0;
			do
			{
				start = pos;
				pos = [self getDataFrom:szLine Pos:start To:szData];
				while(strlen(szData) > 0 && szData[strlen(szData)-1] == ' ') szData[strlen(szData)-1] = 0;
				if(col < [_dictKey count])
				{
					NSString *data = [[NSString alloc] initWithUTF8String:szData];
					NSString *key = [[NSString alloc] initWithFormat:@"%d@%@", _lineCount, [_dictKey objectAtIndex:col]];
					[_dictData setObject:data forKey:key];
				}
				col++;
			} while(pos != start);
			_lineCount++;
		}
	}
	
	fclose(fp);
	return self;
}*/

- (void)dealloc
{
	[_dictKey release];
	[_dictData release];
	[super dealloc];
}

- (int)getDataFrom:(const char *)szLine Pos:(int)pos To:(char *)output
{
	int start = pos;
	bool bEnd = false;

	while(!bEnd)
	{
		if(szLine[pos] == '\t' || szLine[pos] == '\n' || szLine[pos] == '\0')
		{
			if(start != pos)
			{
				strncpy(output, szLine + start, pos - start);
				output[pos - start] = 0;
			}
			else
			{
				*output = 0;
			}
		
			if(szLine[pos] == '\t' || szLine[pos] == '\n') pos++;
			bEnd = true;
		}
		else
		{
			pos++;
		}
	}
	
	return pos;
}

- (NSString *)getKey:(int)column
{
	return [_dictKey objectAtIndex:column];
}

- (NSString *)getString:(int)line Key:(NSString *)key
{
	return [_dictData objectForKey:[NSString stringWithFormat:@"%d@%@", line, key]];
}

- (int)getInt:(int)line Key:(NSString *)key
{
	NSString *string = [self getString:line Key:key];
	if(string != nil)
	{
		char szNum[24], *tmp = szNum;
		strcpy(szNum, [string UTF8String]);
		while(*tmp != 0)
		{
			if(*tmp == ',') memmove(tmp, tmp + 1, strlen(tmp));
			else tmp++;
		}
		return atoi(szNum);
	}
	
	return 0;
}

- (float)getFloat:(int)line Key:(NSString *)key
{
	NSString *string = [self getString:line Key:key];
	if(string != nil)
	{
		char szNum[24], *tmp = szNum;
		strcpy(szNum, [string UTF8String]);
		while(*tmp != 0)
		{
			if(*tmp == ',') memmove(tmp, tmp + 1, strlen(tmp));
			else tmp++;
		}
		return atof(szNum);
	}
	
	return 0.f;
}


@end

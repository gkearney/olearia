//
//  BBSTBCommonDocClass.m
//  TalkingBook Framework
//
//  Created by Kieren Eaton on 9/12/08.
//  Copyright 2008 BrainBender Software. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "BBSTBCommonDocClass.h"

@interface BBSTBCommonDocClass ()

@property (readwrite, copy)	NSString	*currentLevelString;
@property (readwrite, copy)	NSString	*currentPageString;

@end

static BBSTBCommonDocClass *sharedInstanceManager = nil;

@implementation BBSTBCommonDocClass

+ (BBSTBCommonDocClass *)sharedInstance
{
    @synchronized(self) 
	{
        if (sharedInstanceManager == nil) 
		{
            [[self alloc] init]; 
        }
		

    }
	
    return sharedInstanceManager;
	
}


- (id) init
{
	if (!sharedInstanceManager) 
	{
		sharedInstanceManager = [super init];
		
	}
	else
		[self dealloc];
	
    [self resetForNewBook];
	
    return sharedInstanceManager;
}

- (void)resetForNewBook
{
	self.bookTitle = @"Olearia";
	self.bookSubject = @"";
	self.currentLevelString = @"";
	self.currentPageString = @"";
	self.currentSectionTitle = @"";
	self.bookTotalTime = @""; 
	
	self.hasNextChapter = NO;
	self.hasPreviousChapter = NO;
	self.hasLevelUp = NO;
	self.hasLevelDown = NO;
	self.hasNextSegment = NO;
	self.hasPreviousSegment = NO;
	
}

#pragma mark -
#pragma mark ====== Accessors =====

- (void)setCurrentLevel:(NSInteger)aLevel
{
	currentLevel = aLevel;
	currentLevelString = [NSString stringWithFormat:@"%d",aLevel];
}

- (void)setCurrentPage:(NSInteger)aPage
{
	currentPage = aPage;
	currentPageString = [NSString stringWithFormat:@"%d of %d",currentPage,totalPages];
}

- (void)setMediaFormatFromString:(NSString *)mediaTypeString
{
	
	if(mediaTypeString != nil)
	{
		NSString *typeStr = [mediaTypeString lowercaseString];
		// set the mediaformat accordingly
		if([typeStr isEqualToString:@"audiofulltext"])
			mediaFormat = AudioFullTextMediaFormat;
		else if([typeStr isEqualToString:@"audioparttext"])
			mediaFormat = AudioPartialTextMediaFormat;
		else if([typeStr isEqualToString:@"audioonly"])
			mediaFormat = AudioOnlyMediaFormat;
		else if([typeStr isEqualToString:@"audioncc"])
			mediaFormat = AudioNcxOrNccMediaFormat;
		else if([typeStr isEqualToString:@"textpartaudio"])
			mediaFormat = TextPartialAudioMediaFormat;
		else if([typeStr isEqualToString:@"textncc"])
			mediaFormat = TextNcxOrNccMediaFormat;
		else 
			mediaFormat = unknownMediaFormat;		
	}
	else
		mediaFormat = unknownMediaFormat;

}


// bindings related
@synthesize bookTitle, bookSubject, currentSectionTitle, bookTotalTime;
@synthesize bookType, mediaFormat;
@synthesize currentLevel, currentLevelString;
@synthesize currentPage, totalPages, currentPageString;

@synthesize hasNextChapter, hasPreviousChapter;
@synthesize hasLevelUp, hasLevelDown;
@synthesize hasNextSegment, hasPreviousSegment;

@end
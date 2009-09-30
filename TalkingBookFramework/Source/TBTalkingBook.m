//
//  TBTalkingBook.m
//  TalkingBook Framework
//
//  Created by Kieren Eaton on 5/05/08.
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

#import "TBTalkingBook.h"
#import <QTKit/QTKit.h>

@interface TBTalkingBook ()

@property (readwrite, retain)	NSMutableArray	*formatPlugins;
//@property (readwrite)		TalkingBookType _controlMode;

@property (readwrite)	BOOL	_wasPlaying;

// Bindings related
@property (readwrite)	BOOL	canPlay;


@end

@interface TBTalkingBook (Private)

- (void)errorDialogDidEnd;
- (void)resetBook;

// Plugin Loading and Validation
- (BOOL)plugInClassIsValid:(Class)plugInClass;
- (void)loadPlugins;
- (NSArray *)availBundles;

@end


@implementation TBTalkingBook

- (id) init
{
	if (!(self=[super init])) return nil;
	
	self.bookData = [TBBookData sharedBookData];
	
	formatPlugins = [[NSMutableArray alloc] init];
	[self loadPlugins];
	
	[self resetBook];
	
	bookIsLoaded = NO;
	
	infoPanel = nil;
	infoView = nil;
	textView = nil;
	
	return self;
}



- (void) dealloc
{
	[infoPanel release];
	[textWindow release];

	currentPlugin = nil;
	[formatPlugins release];
	
	
	[super dealloc];
}


- (BOOL)openBookWithURL:(NSURL *)aURL
{
	// reset everything ready for a new book to be loaded
	[self resetBook];
	
	BOOL bookDidOpen = NO;
	
	// iterate throught the formatPlugins to see if one will open the URL correctly 
	for(id thePlugin in formatPlugins)
	{
#ifdef DEBUG
		NSLog(@"Checking Plugin : %@",[thePlugin description]);
#endif
		
		if([thePlugin openBook:aURL])
		{	
			// set the currentplugin to the plugin that did open the book
			currentPlugin = thePlugin;
			bookDidOpen = YES;
			bookIsLoaded = YES;
			self.canPlay = YES;
			if([infoPanel isVisible])
			{	
				[infoView addSubview:[currentPlugin bookInfoView]];
				
			}
			if([textWindow isVisible])
			{	
				[textView replaceSubview:[[textView subviews] objectAtIndex:0] with:[currentPlugin bookTextView]];
				[[currentPlugin bookTextView] setFrame:[textView frame]];
			}
			break;
		}
	}
	
	
	return bookDidOpen;
	
}

- (void)updateSkipDuration:(float)newDuration
{
	self.bookData.chapterSkipDuration = QTMakeTimeWithTimeInterval((double)newDuration * (double)60);
}

#pragma mark -
#pragma mark Play Methods

- (void)play
{
	[currentPlugin startPlayback];
}

- (void)pause
{	
	[currentPlugin stopPlayback];
}


#pragma mark -
#pragma mark Navigation Methods

- (void)nextSegment
{
	if([currentPlugin respondsToSelector:@selector(nextReadingElement)])
		[currentPlugin nextReadingElement];
}

- (void)previousSegment 
{
	if([currentPlugin respondsToSelector:@selector(previousReadingElement)])
		[currentPlugin previousReadingElement];
}

- (void)upOneLevel
{
	if([currentPlugin respondsToSelector:@selector(upLevel)])
	{
		[currentPlugin upLevel];
	}
	
}

- (void)downOneLevel
{
	if([currentPlugin respondsToSelector:@selector(downLevel)])
	{
		[currentPlugin downLevel];
	}
}

- (void)fastForwardAudio
{
	if([currentPlugin respondsToSelector:@selector(nextAudioSkipPoint)])
	{
		
	}
		//	if(_smilDoc)
	//	{
	//		if(bookData.hasNextChapter)
	//			[_smilDoc nextChapter];
	//
	//	}
	
	//	BOOL segmentAvailable = NO;
	//	QTTime timeOffset = QTZeroTime;
	//	
	//	
	//	// check if we are moving to a chapter in the current audio file
	//	if((_currentChapterIndex + 1) < _totalChapters)
	//	{
	//		_currentChapterIndex++;
	//		[_currentAudioFile setCurrentTime:[_currentAudioFile startTimeOfChapter:_currentChapterIndex]];
	//	}
	//	else 
	//	{
	//		if(_hasControlFile)
	//		segmentAvailable = [_controlDoc nextSegmentIsAvailable];
	//		
	//		if(segmentAvailable)
	//		{
	//			// the next chapter will be in the next audio file
	//
	//			// calculate the current time left in the currently playing file 
	//			QTTime timeLeft = QTTimeDecrement([_currentAudioFile duration], [_currentAudioFile currentTime]);
	//			
	//			// decrement the skip duration by how much time is left
	//			timeOffset = QTTimeDecrement(_skipDuration, timeLeft);
	//
	//			[self nextSegment];
	//			// check if there is a segment available after the one we just moved to
	//			segmentAvailable = [_controlDoc nextSegmentIsAvailable];
	//	
	//			//check if the segment loaded has a shorter duration than the offset
	//			while((QTTimeCompare([_currentAudioFile duration], timeOffset) == NSOrderedAscending) && segmentAvailable)
	//			{
	//				if(segmentAvailable)
	//				{
	//					// the current duration is shorter so decrment the offset by the duration of the segment
	//					timeOffset = QTTimeDecrement(timeOffset, [_currentAudioFile duration]);
	//					
	//					// now go to the next segment
	//					[self nextSegment];
	//					
	//					// check if there is a segment available after the one we just moved to
	//					segmentAvailable = [_controlDoc nextSegmentIsAvailable];					
	//				}
	//				else
	//				{
	//					timeOffset = QTZeroTime;
	//				}
	//			}
	//			
	//			// check that we dont have a zero time spec
	//			if(QTTimeCompare(timeOffset, QTZeroTime) != NSOrderedSame)
	//			{
	//				[_currentAudioFile setCurrentTime:timeOffset];
	//			}
	//		}
	//	}
	//	
	//	[_currentAudioFile play];
	//	[self updateForPosInBook];
}

- (void)fastRewindAudio
{
	if([currentPlugin respondsToSelector:@selector(previousAudioSkipPoint)])
	{
		
	}
		//	if(_smilDoc)
	//	{
	//		if(bookData.hasPreviousChapter)
	//			[_smilDoc previousChapter];
	//	}
	
	
	//	BOOL segmentAvailable = NO;
	//	
	//	if((_currentChapterIndex - 1) >= 0)
	//	{
	//		_currentChapterIndex--;
	//		[_currentAudioFile setCurrentTime:[_currentAudioFile startTimeOfChapter:_currentChapterIndex]];
	//	}
	//	else
	//	{
	//		
	//		if(_hasControlFile)
	//			segmentAvailable = [_controlDoc PreviousSegmentIsAvailable] ;
	//		
	//		if(segmentAvailable)
	//		{
	//			// the previous chapter will be in the previous audio file
	//
	//			// calculate the offset from the currently playing file 
	//			QTTime timeOffset = QTTimeDecrement(_skipDuration, [_currentAudioFile currentTime]);
	//			
	//			// set the flag for reverse chapter navigation
	//			[_controlDoc setNavigateForChapters:YES]; 
	//			
	//			// go to the previous segment
	//			[self previousSegment];
	//			
	//			// check if there is a segment available before one we just moved to
	//			segmentAvailable = [_controlDoc PreviousSegmentIsAvailable];
	//			
	//			//check if the segment loaded has a shorter duration than the offset
	//			while((QTTimeCompare([_currentAudioFile duration], timeOffset) == NSOrderedAscending) && segmentAvailable)
	//			{
	//				if(segmentAvailable)
	//				{
	//					// the current duration is shorter so decrment the offset by the duration of the segment
	//					timeOffset = QTTimeDecrement(timeOffset, [_currentAudioFile duration]);
	//					
	//					// set the flag for reverse chapter navigation
	//					[_controlDoc setNavigateForChapters:YES];
	//					
	//					// now go to the previous segment
	//					[self previousSegment];
	//					
	//					segmentAvailable = [_controlDoc PreviousSegmentIsAvailable];
	//				}
	//				else
	//				{
	//					timeOffset = QTZeroTime;
	//				}
	//			}
	//			
	//			// check that we dont have a zero time spec
	//			if(QTTimeCompare(timeOffset, QTZeroTime) != NSOrderedSame)
	//			{
	//				// check that the duration is greater than the offset
	//				if(QTTimeCompare([_currentAudioFile duration], timeOffset) == NSOrderedDescending)
	//				{
	//					// calculate the offset into the new current file from the end of the audio
	//					QTTime timeToSkipTo = QTTimeDecrement([_currentAudioFile duration], timeOffset);
	//					
	//					// set the now current segments time position
	//					[_currentAudioFile setCurrentTime:timeToSkipTo];
	//					
	//				}
	//			}
	//		}
	//	}
	//	
	//	[_currentAudioFile play];
	//	[self updateForPosInBook];
	
}

- (void)gotoPage
{
	
}

#pragma mark -
#pragma mark Position Loading & Saving

- (void)jumpToPoint:(NSString *)aNodePath andTime:(NSString *)aTimeStr
{
	if(aNodePath)
		[currentPlugin jumpToControlPoint:aNodePath andTime:aTimeStr];
	
}

- (NSString *)currentTimePosition
{
	if([currentPlugin respondsToSelector:@selector(currentPlaybackTime)])
		return [currentPlugin currentPlaybackTime]; 
	
	return nil;
}

- (NSString *)currentControlPositionID
{
	if([currentPlugin respondsToSelector:@selector(currentControlPoint)])
		return [currentPlugin currentControlPoint];

	return nil;
}


#pragma mark -
#pragma mark View Methods

- (void)showHideBookInfo
{
	if(infoPanel)
	{
		if([infoPanel isVisible])
			[infoPanel orderOut:nil];
		else
		{
			[infoView addSubview:[currentPlugin bookInfoView]];
			[infoPanel makeKeyAndOrderFront:self];
		}
	}
	else
		if([NSBundle loadNibNamed:@"TBBookInfo" owner:self])
		{	
			[infoView addSubview:[currentPlugin bookInfoView]];
			[infoPanel makeKeyAndOrderFront:self];
		}
	
	
}

- (void)showHideTextWindow
{
	if(textWindow)
	{
		if([textWindow isVisible])
			[textWindow orderOut:nil];
		else
		{

			[textView replaceSubview:[[textView subviews] objectAtIndex:0] with:[currentPlugin bookTextView]];
			[[currentPlugin bookTextView] setFrame:[textView frame]];
			
			[textWindow makeKeyAndOrderFront:self];
		}
	}
	else
		if([NSBundle loadNibNamed:@"TBTextWindow" owner:self])
		{	
			if(currentPlugin)
			{
				[textView addSubview:[currentPlugin bookTextView]];
				[[currentPlugin bookTextView] setFrame:[textView frame]];
			}
		}
}


- (NSDictionary *)getCurrentPageInfo
{
	return nil;
}

#pragma mark -
#pragma mark Overridden Attribute Methods

- (void)setPreferredVoice:(NSString *)aVoiceID;
{
	bookData.preferredVoice = aVoiceID;
}




- (void)setAudioPlayRate:(float)aRate
{
	self.bookData.audioPlaybackRate = aRate;
}

- (void)setAudioVolume:(float)aVolumeLevel
{
	self.bookData.audioPlaybackVolume = aVolumeLevel;
}

@synthesize formatPlugins, currentPlugin;

@synthesize bookData;

//@synthesize _controlMode;
@synthesize _wasPlaying;
@synthesize bookIsLoaded;


//bindings
@synthesize canPlay;

@end

@implementation TBTalkingBook (Private)


- (void)resetBook
{
	
	bookIsLoaded = NO;
	
	_levelNavConMode = levelNavigationControlMode; // set the default level mode
	_maxLevelConMode = levelNavigationControlMode; // set the default max level mode. 
//	_controlMode = UnknownBookType; // set the default control mode to unknown
	
	_hasPageNavigation = NO;
	_hasPhraseNavigation = NO;
	_hasSentenceNavigation = NO;
	_hasWordNavigation = NO;
	
	self.canPlay = NO;
	
	[bookData resetForNewBook];
	
	if(currentPlugin)
		[currentPlugin reset];
}

- (void)errorDialogDidEnd
{
	[self resetBook];
}

// Plugin Loading and Validation

- (BOOL)plugInClassIsValid:(Class)plugInClass
{    
	if([plugInClass conformsToProtocol:@protocol(TBPluginInterface)])
		return YES;
	
	return NO;
}




- (void)loadPlugins
{
	NSArray *bundlePaths = [self availBundles];
	if([bundlePaths count])
	{
		for (NSString *pluginPath in bundlePaths) 
		{
			NSBundle* pluginBundle = [[[NSBundle alloc] initWithPath:pluginPath] autorelease];
			if (YES == [pluginBundle load])
			{
				if([self plugInClassIsValid:[pluginBundle principalClass]])
					[formatPlugins addObjectsFromArray:[[pluginBundle principalClass] plugins]];
			}
		}
	}
	else 
	{
		// put up a dialog saying that there were no plugins found
		NSAlert *anAlert = [[NSAlert alloc] init];
		[anAlert setMessageText:NSLocalizedString(@"No Plugins Found", @"No plugins found short msg")];
		[anAlert setInformativeText:NSLocalizedString(@"There were no suitable plugins available.\nPlease put them in the correct folder\nand restart the application.",@"no plugins found long msg")];
		[anAlert setAlertStyle:NSWarningAlertStyle];
		[anAlert setIcon:[NSApp applicationIconImage]];
		// we dont need a response from the user so set all options except window to nil;
		[anAlert beginSheetModalForWindow:[NSApp mainWindow]
							modalDelegate:nil 
						   didEndSelector:nil 
							  contextInfo:nil];
		anAlert = nil;
		
	}

}

- (NSArray *)availBundles
{
	NSArray *librarySearchPaths;
	NSString *currPath;
	NSMutableArray *bundleSearchPaths = [NSMutableArray array];
	NSMutableArray *allBundles = [NSMutableArray array];
	
	librarySearchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask - NSSystemDomainMask, YES);

	NSString *appName =[[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
	for(currPath in librarySearchPaths)
	{
		[bundleSearchPaths addObject:[currPath stringByAppendingPathComponent:appName]];
	}
	
	[bundleSearchPaths addObject:[[NSBundle mainBundle] builtInPlugInsPath]];
	
	for(currPath in bundleSearchPaths)
	{
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currPath error:nil];
		if(dirContents)
			for(NSString *currBundlePath in dirContents)
			{
				if([[currBundlePath pathExtension] isEqualToString:@"plugin"])
					[allBundles addObject:[currPath stringByAppendingPathComponent:currBundlePath]];
			}
	}
	
	return allBundles;
}

- (BOOL)windowShouldClose:(id)sender
{
	if(sender == textWindow)
	{	
		[sender orderOut:nil];
		return NO;
	}
	else if(sender == infoPanel)
		infoPanel = nil;
	
	return YES;
}

@end

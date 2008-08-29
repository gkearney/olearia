//
//  OleariaDelegate.h
//  Olearia
//
//  Created by Kieren Eaton on 4/05/08.
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

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@class BBSTalkingBook, OleariaPrefsController;

@interface OleariaDelegate : NSObject
{
	NSArray				*validFileTypes;
	BBSTalkingBook		*talkingBook;
	
	OleariaPrefsController *prefsController;
	
	BOOL				isPlaying;

	NSRect				navBoxOrigSize;
	NSRect				toolBoxOrigSize;
	
	IBOutlet NSWindow	*mainWindow;
	
	IBOutlet NSView			*soundView;
	IBOutlet NSView			*toolsView;
	IBOutlet NSBox			*toolsBox;
	
	IBOutlet NSButton		*playPauseButton;
	IBOutlet NSButton		*nextButton;
	IBOutlet NSButton		*prevButton;
	IBOutlet NSButton		*upLevelButton;
	IBOutlet NSButton		*downLevelButton;
	IBOutlet NSButton		*fastForwardButton;
	IBOutlet NSButton		*fastBackButton;
	IBOutlet NSButton		*infoButton;
	IBOutlet NSButton		*bookmarkButton;
	IBOutlet NSButton		*gotoPageButton;
	
	IBOutlet NSTextField	*currentLevelTextfield;
	IBOutlet NSTextField	*currentPageTextfield;
	IBOutlet NSTextField	*segmentTitleTextfield;
	
	IBOutlet NSSlider		*playbackSpeedSlider;
	IBOutlet NSSlider		*playbackVolumeSlider;
	IBOutlet NSTextField	*playbackSpeedTextfield;
	IBOutlet NSTextField	*playbackVolumeTextfield;

	IBOutlet NSMenuItem		*playPauseMenuItem;
	IBOutlet NSMenuItem		*upLevelMenuItem;
	IBOutlet NSMenuItem		*downLevelMenuItem;
	IBOutlet NSMenuItem		*nextSegmentMenuItem;
	IBOutlet NSMenuItem		*prevSegmentMenuItem;
	IBOutlet NSMenuItem		*fastForwardMenuItem;
	IBOutlet NSMenuItem		*fastBackMenuItem;
	
}

//- (IBAction)displayVolumeRateView:(id)sender;
- (IBAction)displayPrefsPanel:(id)sender;

- (IBAction)openDocument:(id)sender;
- (IBAction)PlayPause:(id)sender;
- (IBAction)upLevel:(id)sender;
- (IBAction)downLevel:(id)sender;
- (IBAction)nextSegment:(id)sender;
- (IBAction)previousSegment:(id)sender;
- (IBAction)fastForward:(id)sender;
- (IBAction)fastRewind:(id)sender;
- (IBAction)gotoPage:(id)sender;
- (IBAction)getInfo:(id)sender;
- (IBAction)addBookmark:(id)sender;

- (IBAction)setPlaybackSpeed:(NSSlider *)sender;
- (IBAction)setPlaybackVolume:(NSSlider *)sender;

- (IBAction)showBookmarks:(id)sender;

@property (readwrite,retain) BBSTalkingBook *talkingBook;

@end
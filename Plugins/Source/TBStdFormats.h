//
//  TBStdFormats.h
//  stdDaisyFormats
//
//  Created by Kieren Eaton on 13/04/09.
//  Copyright 2009 BrainBender Software. All rights reserved.
//
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
#import "TBPluginInterface.h"
#import "TBSharedBookData.h"
#import "TBFileUtils.h"
#import "TBPackageDoc.h"
#import "TBControlDoc.h"

@interface TBStdFormats : NSObject<TBPluginInterface> 
{
	TBSharedBookData	*bookData;
	TBFileUtils			*fileUtils;
	NSArray				*validFileExtensions;

	
	TBPackageDoc		*packageDocument;
	TBControlDoc		*controlDocument;
}

- (void)setupPluginSpecifics;
+ (id)bookType;

@property (readonly, copy)		NSArray* validFileExtensions;

@property (readwrite,retain)	TBSharedBookData	*bookData;
@property (readwrite, retain)	TBPackageDoc		*packageDocument;
@property (readwrite, retain)	TBControlDoc		*controlDocument;

@end

//
//  TBBooksharePlugin.m
//  StdDaisyFormats
//
//  Created by Kieren Eaton on 20/05/09.
//  Copyright 2009 BrainBender Software. All rights reserved.
//

#import "TBBooksharePlugin.h"
#import "TBOPFDocument.h"
#import "TBNCXDocument.h"


@implementation TBBooksharePlugin

+ (TBBooksharePlugin *)bookType
{
	TBBooksharePlugin *instance = [[[self alloc] init] autorelease];
	if (instance)
	{	
		[instance setupPluginSpecifics];
		return instance;
	}
	
	return nil;
}

- (id)variantOfType
{
	// return nil as a default because not all plugins will be variants
	return [self superclass];
}

- (id)textPlugin
{
	
}

- (id)smilPlugin
{
	// Text Only Book so no need for a SMIL plugin
	// we return nil here as a courtesy for complete code introspection
	// as it is already nil in the supers superclass
	return nil;
}

- (void)setupPluginSpecifics
{
	validFileExtensions = [NSArray arrayWithObjects:@"opf",@"ncx",nil];

}


// this method checks the url for a file with a valid extension
// if a directory URL is passed the 
- (BOOL)canOpenBook:(NSURL *)bookURL;
{
	NSURL *fileURL = nil;
	// first check if we were passed a folder
	if ([fileUtils URLisDirectory:bookURL])
	{	// we were so first check for an OPF file 
		fileURL = [fileUtils fileURLFromFolder:[bookURL path] WithExtension:@"opf"];
		// check if we found the OPF file
		if (!fileURL)
			// check for the NCX file
			fileURL = [fileUtils fileURLFromFolder:[bookURL path] WithExtension:@"ncx"];
		if (fileURL)
			return YES;		
	}
	else
	{
		// check the path contains a file with a valid extension
		if([fileUtils URL:bookURL hasExtension:validFileExtensions])
			return YES;
	}
	
	// this did not find a valid extension that it could attempt to open
	return NO;
}


- (BOOL)openBook:(NSURL *)bookURL
{
	BOOL opfLoaded = NO;
	BOOL ncxLoaded = NO;
	NSURL *controlFileURL = nil;
	NSURL *packageFileUrl = nil;
	
	// do a sanity check first to see that we can attempt to open the book. 
	BOOL isValidUrl = [self canOpenBook:bookURL];
	
	if(isValidUrl)
	{
		
		// first check if we were passed a folder
		if ([fileUtils URLisDirectory:bookURL])
		{	
			self.bookData.folderPath = bookURL;
			// passed a folder so first check for an OPF file 
			packageFileUrl = [fileUtils fileURLFromFolder:[bookData.folderPath path] WithExtension:@"opf"];
			// check if we found the OPF file
			if (!packageFileUrl)
				// no opf file found so check for the NCX file
				controlFileURL = [fileUtils fileURLFromFolder:[bookData.folderPath path] WithExtension:@"ncx"];
		}
		else
		{
			// file url
			// check the path contains a file with a valid extension
			if([fileUtils URL:bookURL hasExtension:validFileExtensions])
			{	
				NSString *filename = [bookURL path];
				// check for an opf extension
				if(YES == [[[filename pathExtension] lowercaseString] isEqualToString:@"opf"])
				{
					packageFileUrl = bookURL;
				}
				else if(YES == [[[filename pathExtension] lowercaseString] isEqualToString:@"ncx"])
				{
					// check if there is an OPF file to use instead
					packageFileUrl = [fileUtils fileURLFromFolder:[bookURL path] WithExtension:@"opf"];
					// check if we found the OPF file
					if (!packageFileUrl)
					{
						// no OPF file found fall back to the ncx one instead
						// this should not happen that often but might occasionally 
						// with badly authored books.
						controlFileURL = bookURL;  
						
						self.packageDocument = nil;
					}
					
				}
			}
			
		}
		
		if(packageFileUrl)
		{
			packageDocument = [[TBOPFDocument alloc] init];
			if([packageDocument openWithContentsOfURL:packageFileUrl])
			{
				// the opf file opened correctly
				// get the dc:Format node string
				NSString *bookFormatString = [[packageDocument stringForXquery:@"dc-metadata/data(*:Format)" ofNode:[packageDocument metadataNode]] uppercaseString];
				
				if(YES == [bookFormatString isEqualToString:@"ANSI/NISO Z39.86-2002"]) 
					if(nil != ([[packageDocument metadataNode] objectsForXQuery:@"dc-metadata/*:Identifier[@scheme='BKSH']/." error:nil]))
					{
						// the opf file specifies that it is a 2002 format book
						self.bookData.folderPath = [[NSURL alloc] initFileURLWithPath:[[packageFileUrl path] stringByDeletingLastPathComponent] isDirectory:YES];
						
						// get the ncx filename
						packageDocument.ncxFilename = [packageDocument stringForXquery:@"/package/manifest/item[@media-type='text/xml' ] [ends-with(@href,'.ncx')] /data(@href)" ofNode:nil];
						// get the text content filename
						packageDocument.textContentFilename = [packageDocument stringForXquery:@"/package/manifest/item[@media-type='text/xml' ] [ends-with(@href,'.xml')] /data(@href)" ofNode:nil];
						[packageDocument processData];
						controlFileURL = [NSURL URLWithString:[packageDocument ncxFilename] relativeToURL:bookData.folderPath];  
						
						opfLoaded = YES;
					}
			}
		}
		
		if (controlFileURL)
		{
			controlDocument = [[TBNCXDocument alloc] init];
			// check if the folder path has already been set
			if (!bookData.folderPath)
				self.bookData.folderPath = [NSURL URLWithString:[[controlFileURL path] stringByDeletingLastPathComponent]];
			// attempt to load the ncx file
			
		}
	}
	
	// return YES if the Package document and/or Control Document loaded correctly
	// as we can do limited control and playback functions from the opf file this is a valid scenario.
	return (((nil != packageFileUrl) && opfLoaded) || ((nil != controlFileURL) && ncxLoaded));
}

#pragma mark -

- (void) dealloc
{
	
	[super dealloc];
}


@end
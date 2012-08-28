//
//  helpers.m
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "helpers.h"



NSString *replaceParagraphsWithNewLine(NSString *html)
{
	NSString *paragraphTag = @"<p>";
	NSArray *replaceWithNewLineArray = [NSArray arrayWithObjects:@"</p>", @"</br>", @"</ br>", 
										@"<br>", @"<br/>", @"<br />", nil];
	
	html = [html stringByReplacingOccurrencesOfString:paragraphTag
										   withString:@""];
	int i = replaceWithNewLineArray.count;
	while (i--) {
		NSString *toReplace = [replaceWithNewLineArray objectAtIndex:i];
		html = [html stringByReplacingOccurrencesOfString:toReplace
											   withString:@"\n"];		
	}
	
    return html;
}
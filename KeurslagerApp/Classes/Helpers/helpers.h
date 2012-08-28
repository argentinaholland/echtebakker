//
//  helpers.h
//  EasyTrip
//
//  Created by mac-227 on 27.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBHEXCOLOR(r,g,b)			[UIColor colorWithRed: r/255.f green: g/255.f blue: b/255.f alpha:1.0f]
#define RGBHEXCOLOR_WITH_ALPHA(r,g,b,a)	[UIColor colorWithRed: r/255.f green: g/255.f blue: b/255.f alpha: a]
#define HEXCOLOR(c)					[UIColor colorWithRed: ((c >> 16) & 0xFF)/255.f green: ((c >> 8) & 0xFF)/255.f blue: (c & 0xFF)/255.f alpha: 1.0f]
#define HEXCOLOR_WITH_ALPHA(c, a)	[UIColor colorWithRed: ((c >> 16) & 0xFF)/255.f green: ((c >> 8) & 0xFF)/255.f blue: (c & 0xFF)/255.f alpha: a]



NSString *replaceParagraphsWithNewLine(NSString *html);

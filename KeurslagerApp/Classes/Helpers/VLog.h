//
//  VLog.h
//  
//
//  Created by Botond Szekely on 7/9/10.
//  Copyright 2010 Halcyon Mobile. All rights reserved.
//


//#define MESURE_TIME_MODE

#ifdef DEBUG

#define VLog( s, ... ) NSLog ( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define VLog

#endif	// DEBUG_MODE


#ifdef MESURE_TIME_MODE

#define BeginTimeLog()		NSDate *start__ = [NSDate date]
#define EndTimeLog()		NSLog ( @"<%@:(%d)>   elapsed time = %.1f ms", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [[NSDate date] timeIntervalSinceDate:start__] * 1000. )

#else

#define BeginTimeLog()
#define EndTimeLog()

#endif	// MESURE_TIME_MODE

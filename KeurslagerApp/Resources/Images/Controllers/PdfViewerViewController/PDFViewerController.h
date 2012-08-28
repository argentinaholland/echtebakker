//
//  PDFViewerController.h
//  PDFReader
//

#import <UIKit/UIKit.h>

@interface PDFViewerController : UIViewController 
{
	
}

- (id) initWithArrayOfPDFFiles: (NSArray *) pdfFiles
			andUnlockPasswords: (NSArray *) pdfFilesPasswords
					  andTitle: (NSString *) title
					andPdfUNID: (NSString *) pdfUNID;

@end
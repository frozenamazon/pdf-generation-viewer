//
//  ViewController.m
//  pdfGenerator
//
//  Created by Lisa Lau on 09/02/2017.
//  Copyright © 2017 Lisa Lau. All rights reserved.
//

#import "ViewController.h"
#define kPadding 20

@interface ViewController ()

@end


@implementation ViewController

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"html"]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    
    [webView loadRequest:req];
}

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height {
    _pageSize = CGSizeMake(width, height);
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentsDirectory);
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];
    
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
}

- (void)beginPDFPage {
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pageSize.width, _pageSize.height), nil);
}

- (float)addText:(NSString*)text atPos:(float)posY {
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(_pageSize.width, _pageSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    float textWidth = _pageSize.width - kPadding * 2;
    
    CGRect renderingRect = CGRectMake(kPadding, posY, textWidth, rect.size.height);
    [text drawInRect:renderingRect withAttributes:attributes];
    
    return renderingRect.origin.y + rect.size.height;
}

- (float)addLineWithFrame:(float)posY withColor:(UIColor*)color withThickness:(float)width {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    // this is the thickness of the line
    CGContextSetLineWidth(currentContext, width);
    
    CGPoint startPoint = CGPointMake(kPadding, posY + kPadding);
    CGPoint endPoint = CGPointMake(_pageSize.width - 2 * kPadding, posY + kPadding);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    return endPoint.y;
}

- (float)addImage:(UIImage*)image atPos:(float)posY {
    CGRect imageFrame = CGRectMake((_pageSize.width/2)-(image.size.width/2), posY + kPadding, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
    return imageFrame.origin.y + imageFrame.size.height;
}

- (IBAction) htmlToPdfButtonPressed:(id)sender {
    [self setupPDFDocumentNamed:@"Yoshi" Width:850 Height:1100];
    [self beginPDFPage];
    
    float nextPos = kPadding;
    
    nextPos = [self addText:@"This is some nice text here, don't you agree?" atPos:kPadding];
    
    nextPos = [self addLineWithFrame:nextPos withColor:[UIColor blueColor] withThickness:1];
    UIImage *anImage = [UIImage imageNamed:@"test.png"];
    nextPos = [self addImage:anImage atPos:nextPos];
    [self addLineWithFrame:nextPos withColor:[UIColor redColor] withThickness:1];
    
    [self finishPDF];
    
}

- (IBAction)viewPdf:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"Yoshi.pdf"];
    
    NSURL *url = [NSURL fileURLWithPath:pdfPath];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
}

- (IBAction)GenMultiPage:(id)sender {
    
    [self setupPDFDocumentNamed:@"CurrentView" Width:850 Height:1100];
    [self beginPDFPage];
    NSMutableData* pdfData = [NSMutableData data];
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(pdfContext, 0.773f, 0.773f);
    [self.view.layer renderInContext:pdfContext];
    
    UIGraphicsEndPDFContext();
}



- (void)finishPDF {
    UIGraphicsEndPDFContext();
}

//- (IBAction)didClickOpenPDF {
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"NewPDF.pdf"];
//    
//    if([[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
//        
//        ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfPath password:nil];
//        
//        if (document != nil)
//        {
//            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
//            readerViewController.delegate = self;
//            
//            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
//            
//            [self presentModalViewController:readerViewController animated:YES];
//        }
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

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

- (CGRect)addText:(NSString*)text withFrame:(CGRect)frame fontSize:(float)fontSize {
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(_pageSize.width, _pageSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    float textWidth = frame.size.width;
    
    if (textWidth < rect.size.width)
        textWidth = rect.size.width;
    if (textWidth > _pageSize.width)
        textWidth = _pageSize.width - frame.origin.x;
    
    CGRect renderingRect = CGRectMake(frame.origin.x, frame.origin.y, textWidth, rect.size.height);
    [text drawInRect:renderingRect withAttributes:attributes];
    
    frame = CGRectMake(frame.origin.x, frame.origin.y, rect.size.width, rect.size.height);
    
    return frame;
}

- (CGRect)addLineWithFrame:(CGRect)frame withColor:(UIColor*)color {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    // this is the thickness of the line
    CGContextSetLineWidth(currentContext, frame.size.height);
    
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    return frame;
}

- (CGRect)addImage:(UIImage*)image atPoint:(CGPoint)point {
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
    return imageFrame;
}

- (IBAction) htmlToPdfButtonPressed:(id)sender {
    [self setupPDFDocumentNamed:@"Yoshi" Width:850 Height:1100];
    [self beginPDFPage];
    
    CGRect textRect = [self addText:@"This is some nice text here, don't you agree?"
                          withFrame:CGRectMake(kPadding, kPadding, 400, 200) fontSize:48.0f];
    
    CGRect blueLineRect = [self addLineWithFrame:CGRectMake(kPadding, textRect.origin.y + textRect.size.height + kPadding, _pageSize.width - kPadding*2, 4)
                                       withColor:[UIColor blueColor]];
    UIImage *anImage = [UIImage imageNamed:@"test.png"];
    CGRect imageRect = [self addImage:anImage
                              atPoint:CGPointMake((_pageSize.width/2)-(anImage.size.width/2), blueLineRect.origin.y + blueLineRect.size.height + kPadding)];
    [self addLineWithFrame:CGRectMake(kPadding, imageRect.origin.y + imageRect.size.height + kPadding, _pageSize.width - kPadding*2, 4) withColor:[UIColor redColor]];
    
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
    
    [self setupPDFDocumentNamed:@"Yoshi" Width:850 Height:1100];
    [self beginPDFPage];
    UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
    testView.backgroundColor = [UIColor blueColor];
    NSMutableData* pdfData = [NSMutableData data];
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(pdfContext, 0.773f, 0.773f);
    [testView.layer renderInContext:pdfContext];
    
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

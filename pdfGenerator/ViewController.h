//
//  ViewController.h
//  pdfGenerator
//
//  Created by Lisa Lau on 09/02/2017.
//  Copyright © 2017 Lisa Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    UIWebView *webView;
    CGSize _pageSize;
}
@property (nonatomic,retain) IBOutlet UIWebView *webView;

- (IBAction) htmlToPdfButtonPressed:(id)sender;
- (IBAction)viewPdf:(id)sender;
- (IBAction)GenMultiPage:(id)sender;

@end


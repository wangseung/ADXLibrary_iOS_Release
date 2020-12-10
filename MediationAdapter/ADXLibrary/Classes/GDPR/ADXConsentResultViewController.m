//
//  ADXConsentResultViewController.m
//  ADXLibrary
//
//  Created by Eleanor Choi on 2018. 5. 29..
//

#import "ADXConsentResultViewController.h"
#import "ADXGDPR.h"

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define TITLE_HEIGHT        70.0
#define SIDE_MARGIN         24.0
#define TOPDOWN_MARGIN      20.0
#define BUTTON_HEIGHT       54.0

@interface ADXConsentResultViewController ()
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UITextView *descTextView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIButton *closeButton;
@property (nonatomic, assign) BOOL isConfirmed;

@end

@implementation ADXConsentResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addConsentUI];
}

- (IBAction)selectClose:(id)sender {
    self.confirmedBlock(TRUE);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self changeFrame:size];
}

- (void)setColorGradientWithStart:(UIColor *)firstColor
                              End:(UIColor *)lastColor
                           toView:(UIView *)view {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(view.bounds.origin.x
                                , view.bounds.origin.y
                                , [[UIScreen mainScreen] bounds].size.width
                                , view.bounds.size.height);
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 0.0);
    gradient.colors = @[(id)firstColor.CGColor, (id)lastColor.CGColor];
    
    for (CAGradientLayer *layer in view.layer.sublayers) {
        [view.layer replaceSublayer:layer with:gradient];
        return;
    }
    
    [view.layer insertSublayer:gradient atIndex:0];
}

- (UIColor *)coralColor {
    return [UIColor colorWithRed:1.0f green:90.0f / 255.0f blue:77.0f / 255.0f alpha:1.0f];
}

- (UIColor *)redPinkColor {
    return [UIColor colorWithRed:253.0f / 255.0f green:23.0f / 255.0f blue:88.0f / 255.0f alpha:1.0f];
}

- (UIColor *)warmGreyColor {
    return [UIColor colorWithRed:153.0f / 255.0f green:153.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
}

- (void)addConsentUI {
    
    float posY = 0.0;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                              posY,
                                                              SCREEN_WIDTH,
                                                              TITLE_HEIGHT)];
    [self.view addSubview:self.titleView];
    
    //*** 타이틀바 그라데이션 처리
    [self setColorGradientWithStart:[self coralColor]
                                End:[self redPinkColor]
                             toView:self.titleView];
    
    UIImage *logoImage = [UIImage imageNamed:@"biForIOs"];
    
    if (logoImage == nil) {
        logoImage = [UIImage imageNamed:@"ADX.bundle/biForIOs"];
    }
    
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                       0.0,
                                                                       self.titleView.frame.size.width,
                                                                       self.titleView.frame.size.height)];
    [self.logoImageView setBackgroundColor:[UIColor clearColor]];
    [self.logoImageView setImage:logoImage];
    [self.logoImageView setContentMode:UIViewContentModeCenter];
    [self.titleView addSubview:self.logoImageView];
    
    posY += self.titleView.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    self.descTextView = [[UITextView alloc] initWithFrame:CGRectMake(SIDE_MARGIN,
                                                                     posY,
                                                                     SCREEN_WIDTH - SIDE_MARGIN*2,
                                                                     SCREEN_HEIGHT - posY - TOPDOWN_MARGIN*2 - BUTTON_HEIGHT)];
    [self.descTextView setBackgroundColor:[UIColor clearColor]];
    [self.descTextView setSelectable:TRUE];
    [self.descTextView setEditable:FALSE];
    [self.descTextView setScrollEnabled:TRUE];
    [self.descTextView setScrollsToTop:TRUE];
    [self.view addSubview:self.descTextView];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(SIDE_MARGIN,
                                                                  SCREEN_HEIGHT - TOPDOWN_MARGIN - BUTTON_HEIGHT,
                                                                  SCREEN_WIDTH - SIDE_MARGIN*2,
                                                                  BUTTON_HEIGHT)];
    [self.closeButton setBackgroundColor:[self warmGreyColor]];
    [self.closeButton setTitle:@"Close this window" forState:UIControlStateNormal];
    [self.closeButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.closeButton.layer setCornerRadius:27.0];
    [self.closeButton addTarget:self action:@selector(selectClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    
    //*** 사용자 동의 상태 확인
    self.isConfirmed = ([ADXGDPR.sharedInstance getConsentState] == ADXConsentStateConfirm)? TRUE : FALSE;
    
    //*** 동의 여부에 따른 디스크립션 변경
    [self changeDescription];
}

- (void)changeDescription {
    
    NSString *descString = nil;
    
    
    if (self.isConfirmed) {
        descString = @"Personalize Your Ad Experience\n\nGreat. We hope you enjoy your personalized ad experience. If you ever change your mind, you can withdraw your consent by enabling Opt out of Ads Personalization under Settings/Privacy/Advertising on your iPhone device and then restarting this app.";
        
        
    } else {
        descString = @"Personalize Your Ad Experience\n\nAD(X) won’t collect your data for personalized advertising in this app. However, if you authorize AD(X) to personalize your advertising experience in a different app, we will collect your data in that other app.";
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:descString];
    
    //*** 줄간격
    NSInteger strLength = [descString length];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setMinimumLineHeight:22];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, strLength)];
    //*** 폰트
    UIFont *normalFont =  [UIFont systemFontOfSize:13.0];
    [attrString addAttribute:NSFontAttributeName
                       value:normalFont
                       range:NSMakeRange(0, strLength)];
    
    NSRange range = [descString rangeOfString:@"Personalize Your Ad Experience"];
    UIFont *mediumFont =  [UIFont boldSystemFontOfSize:20.0];
    [attrString addAttribute:NSFontAttributeName
                       value:mediumFont
                       range:range];
    
    [self.descTextView setAttributedText:attrString];

}

- (void)changeFrame:(CGSize)size {
    
    float width = size.width;
    float height = size.height;

    float posY = 0.0;
    
    [self.titleView setFrame:CGRectMake(0.0,
                                        posY,
                                        width,
                                        (width > height)? TITLE_HEIGHT - 10.0 : TITLE_HEIGHT)];
    
    [self setColorGradientWithStart:[self coralColor]
                                End:[self redPinkColor]
                             toView:self.titleView];
    
    [self.logoImageView setFrame:CGRectMake(0.0,
                                            0.0,
                                            self.titleView.frame.size.width,
                                            self.titleView.frame.size.height)];
    
    posY += self.titleView.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    [self.descTextView setFrame:CGRectMake(SIDE_MARGIN,
                                           posY,
                                           width - SIDE_MARGIN*2,
                                           SCREEN_HEIGHT - posY - BUTTON_HEIGHT - TOPDOWN_MARGIN)];
    
    [self.closeButton setFrame:CGRectMake(SIDE_MARGIN,
                                          height - TOPDOWN_MARGIN - BUTTON_HEIGHT,
                                          width - SIDE_MARGIN*2,
                                          BUTTON_HEIGHT)];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

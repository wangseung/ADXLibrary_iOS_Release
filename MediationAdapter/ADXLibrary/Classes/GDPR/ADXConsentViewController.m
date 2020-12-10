//
//  ADXConsentViewController.m
//  ADXLibrary
//
//  Created by Eleanor Choi on 2018. 5. 29..
//

#import "ADXConsentViewController.h"
#import "ADXConsentResultViewController.h"
#import "ADXGDPR.h"

#define URL_LEARN_MORE  @"https://assets.adxcorp.kr/privacy/partners"

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define TITLE_HEIGHT        70.0
#define SIDE_MARGIN         24.0
#define TOPDOWN_MARGIN      20.0
#define BUTTON_AREA_HEIGHT  200.0
#define BUTTON_HEIGHT       54.0

@interface ADXConsentViewController ()
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UITextView *descTextView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *deniedButton;
@property (strong, nonatomic) UILabel *descLabel;


@end

@implementation ADXConsentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addConsentUI];
    
    
}
- (IBAction)selectYes:(id)sender {
    [self moveResultController:TRUE];
    
}
- (IBAction)selectNo:(id)sender {
    [self moveResultController:FALSE];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self changeFrame:size];
}

- (void)moveResultController:(BOOL)confirmed {
    
    if (confirmed) {
        [ADXGDPR.sharedInstance setConsentState:ADXConsentStateConfirm];
    } else {
        [ADXGDPR.sharedInstance setConsentState:ADXConsentStateDenied];
    }
    
    ADXConsentResultViewController *vc = [[ADXConsentResultViewController alloc] init];
    [vc setConfirmedBlock:self.confirmedBlock];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:vc] animated:FALSE];
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

- (UIColor *)textGreyColor {
    return [UIColor colorWithRed:119.0f / 255.0f green:119.0f / 255.0f blue:119.0f / 255.0f alpha:1.0f];
}

- (void)addConsentUI {
    
    float posY = 0.0;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                              posY,
                                                              SCREEN_WIDTH,
                                                              TITLE_HEIGHT)];
    [self.view addSubview:self.titleView];
    
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
                                                                     SCREEN_HEIGHT - posY - BUTTON_AREA_HEIGHT - TOPDOWN_MARGIN)];
    [self.descTextView setBackgroundColor:[UIColor clearColor]];
    [self.descTextView setSelectable:TRUE];
    [self.descTextView setEditable:FALSE];
    [self.descTextView setScrollEnabled:TRUE];
    [self.descTextView setScrollsToTop:TRUE];
    [self.descTextView setShowsVerticalScrollIndicator:FALSE];
    [self.view addSubview:self.descTextView];
    
    
    NSString *desc = @"Personalize Your Ad Experience\n\nThis app personalizes your advertising experience using AD(X). AD(X) does not collect any data, but our partners may collect and process personal data such as device identifiers, location data, and other demographic and interest data to provide advertising experience tailored to you. By consenting to this improved ad experience, you'll see ads that AD(X) and its partners believe are more relevant to you. Learn more.\n\nBy agreeing, you confirm that you are over the age of 16 and would like a personalized ad experience.";
    
    //*** 폰트
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:desc];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setMinimumLineHeight:22];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.string.length)];
    
    UIFont *normalFont =  [UIFont systemFontOfSize:13.0];
    [attrString addAttribute:NSFontAttributeName
                       value:normalFont
                       range:NSMakeRange(0, attrString.string.length)];
    
    NSRange titleRange = [desc rangeOfString:@"Personalize Your Ad Experience"];
    UIFont *mediumFont =  [UIFont boldSystemFontOfSize:20.0];
    [attrString addAttribute:NSFontAttributeName
                       value:mediumFont
                       range:titleRange];
    
    NSRange linkRange = [desc rangeOfString:@"Learn more"];
    
    
    [attrString setAttributes:@{ NSLinkAttributeName: [NSURL URLWithString:URL_LEARN_MORE],
                                 NSForegroundColorAttributeName : [self coralColor],
                                 NSUnderlineColorAttributeName : [self coralColor],
                                 NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}
                        range:linkRange];
    [self.descTextView setLinkTextAttributes:@{NSForegroundColorAttributeName : [self coralColor]}];
    [self.descTextView setAttributedText:attrString];
    
    posY += self.descTextView.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(SIDE_MARGIN, posY, SCREEN_WIDTH - SIDE_MARGIN*2, BUTTON_HEIGHT)];
    [self.confirmButton setBackgroundColor:[self coralColor]];
    [self.confirmButton setTitle:@"Yes, I agree" forState:UIControlStateNormal];
    [self.confirmButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.confirmButton.layer setCornerRadius:27.0];
    [self.confirmButton addTarget:self action:@selector(selectYes:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    
    posY += self.confirmButton.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    self.deniedButton = [[UIButton alloc] initWithFrame:CGRectMake(SIDE_MARGIN, posY, SCREEN_WIDTH - SIDE_MARGIN*2, BUTTON_HEIGHT)];
    [self.deniedButton setBackgroundColor:[self warmGreyColor]];
    [self.deniedButton setTitle:@"No, Thanks" forState:UIControlStateNormal];
    [self.deniedButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.deniedButton.layer setCornerRadius:27.0];
    [self.deniedButton addTarget:self action:@selector(selectNo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deniedButton];
    
    posY += self.deniedButton.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_MARGIN, posY, SCREEN_WIDTH - SIDE_MARGIN*2, 30.0)];
    [self.descLabel setBackgroundColor:[UIColor clearColor]];
    [self.descLabel setText:@"I understand that I will still see ads, but they may not be as relevant to my interests."];
    [self.descLabel setNumberOfLines:0];
    [self.descLabel setTextAlignment:NSTextAlignmentCenter];
    [self.descLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.descLabel setTextColor:[self textGreyColor]];
    [self.view addSubview:self.descLabel];
    
    [self changeFrame:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
}

- (void)changeFrame:(CGSize)size {
    
    float width = size.width;
    float height = size.height;
    
    BOOL isLandscape = (width > height)? TRUE : FALSE;
    
    float buttonAreaHeight = (isLandscape)? 100.0 : BUTTON_AREA_HEIGHT;
    float buttonWidth = (isLandscape)? (width - SIDE_MARGIN*3)/2 : width - SIDE_MARGIN*2;
    float posY = 0.0;
    
    [self.titleView setFrame:CGRectMake(0.0,
                                        posY,
                                        width,
                                        (isLandscape)? TITLE_HEIGHT - 10.0 : TITLE_HEIGHT)];
    
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
                                           SCREEN_HEIGHT - posY - buttonAreaHeight - TOPDOWN_MARGIN)];
    
    posY += self.descTextView.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    [self.confirmButton setFrame:CGRectMake(SIDE_MARGIN,
                                            posY, buttonWidth, BUTTON_HEIGHT)];
    
    float posX = SIDE_MARGIN;
    
    if (isLandscape) {
        posX = self.confirmButton.frame.origin.x + self.confirmButton.frame.size.width + SIDE_MARGIN;
    } else {
        posY += self.confirmButton.frame.size.height;
        posY += TOPDOWN_MARGIN;
    }
    
    [self.deniedButton setFrame:CGRectMake(posX,
                                           posY,
                                           buttonWidth,
                                           BUTTON_HEIGHT)];
    
    posY += self.deniedButton.frame.size.height;
    posY += TOPDOWN_MARGIN;
    
    [self.descLabel setFrame:CGRectMake(SIDE_MARGIN,
                                        posY,
                                        width - SIDE_MARGIN*2,
                                        (isLandscape)? 20.0 : 30.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

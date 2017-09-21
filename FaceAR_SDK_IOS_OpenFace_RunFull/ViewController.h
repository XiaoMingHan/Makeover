//
//  ViewController.h
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//

#import <UIKit/UIKit.h>

#import <opencv2/videoio/cap_ios.h>

@interface ViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>{
    cv::Mat_<double> face_info;
    cv::Mat_<int> visibilities;
    cv::Mat target_image;
    cv::Mat smooth_image;
    
    UIImage* result_image;
    NSMutableArray *array_image;
    NSMutableArray *mem_array_image;
    int mem_index;
    
}
//- (IBAction)startButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) UIImage* select_Image;
@property (weak, nonatomic) IBOutlet UIButton *complete_button;
@property (weak, nonatomic) IBOutlet UIButton *retouch_button;
@property (weak, nonatomic) IBOutlet UIButton *contour_button;

@property (weak, nonatomic) IBOutlet UISlider *effect_slider;
@property (weak, nonatomic) IBOutlet UICollectionView *img_gallery;


@end


#include <cassert>
#include <fstream>
#include <exception>
#include <opencv2/highgui/highgui.hpp>
#include "text_extraction.hpp"


class FeatureError : public std::exception
{
    std::string message;

public:
    FeatureError ( const std::string & msg, const std::string & file ) {
        std::stringstream ss;

        ss << msg << " " << file;
        message = msg.c_str();
    }

    ~FeatureError () throw ( ) {
    }
};

int
main(int argc, char *argv[])
{
    if(argc != 4) {
        std::cout << "usage: " << argv[0] << " imagefile resultImage darkText" << std::endl;

        return -1;
    }

    cv::Mat inputImage = cv::imread(argv[1]);

    if(!inputImage.data) {
        std::cout << "couldn't load query image" << std::endl;
        return -1;
    }

    // Detect text in the image
    extract_letters(&inputImage, atoi(argv[3]));
    // imwrite(argv[2], output);
}

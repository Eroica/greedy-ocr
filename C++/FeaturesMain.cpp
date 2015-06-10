
/*
    Copyright 2012 Andrew Perrault and Saurav Kumar.

    This file is part of DetectText.

    DetectText is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DetectText is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DetectText.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <cassert>
#include <fstream>
#include <exception>
#include <opencv2/highgui/highgui.hpp>
#include "TextDetection.hpp"


class FeatureError : public std::exception
{
    std::string message;

public:
    FeatureError ( const std::string & msg, const std::string & file )
    {
        std::stringstream ss;

        ss << msg << " " << file;
        message = msg.c_str();
    }

    ~FeatureError () throw ( )
    {
    }
};

int
main(int argc, char *argv[])
{
    if(( argc != 4 )) {
    printf ( "usage: %s imagefile resultImage darkText\n",
             argv[0] );

    return -1;
    }

    Mat inputImage = imread(argv[1]);

    if(!inputImage.data) {
        printf ( "couldn't load query image\n" );
        return -1;
    }

    // Detect text in the image

    Mat output = textDetection(inputImage, atoi(argv[3]));
    imwrite(argv[2], output);
}

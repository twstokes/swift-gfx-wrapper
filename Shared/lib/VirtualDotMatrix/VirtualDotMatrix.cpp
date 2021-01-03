//
//  VirtualDotMatrix.cpp
//  Flipper
//
//  Created by Tanner W. Stokes on 1/2/21.
//

#include "VirtualDotMatrix.hpp"

VirtualDotMatrix::VirtualDotMatrix(int16_t mW, int16_t mH, bool useBuffer)
    : Adafruit_GFX(mW, mH), matrixWidth(mW), matrixHeight(mH), buffer(NULL), drawPixelCallback(NULL), swiftBoard(NULL)
{
    if (useBuffer) {
        // initialize an internal pixel buffer
        buffer = new uint32_t[mW * mH];
    }
}

void VirtualDotMatrix::start(const void *sb = NULL, DrawPixelCallback cb = NULL)
{
    if (cb != NULL) {
        drawPixelCallback = cb;
    }
    
    if (sb != NULL) {
        swiftBoard = sb;
    }
    
    // initialize the board buffer with all zeros
    fillScreen(0);
}

/*
    required implementation by gfx library for drawing
*/
void VirtualDotMatrix::drawPixel(int16_t x, int16_t y, uint16_t color)
{
    if (x < 0 || x >= matrixWidth ||
        y < 0 || y >= matrixHeight)
    {
        // out of bounds
        return;
    }

    if (buffer != NULL) {
        buffer[y*matrixWidth + x] = color;
    }

    if (drawPixelCallback != NULL && swiftBoard != NULL) {
        drawPixelCallback(x, y, color, swiftBoard);
    }
}

/*
    return pixel (x, y) from the buffer
 
    this will return 0 if a buffer isn't available
*/
uint16_t VirtualDotMatrix::getPixel(int16_t x, int16_t y) {
    // we're not using the buffer, so there's nothing to return
    if (buffer == NULL) {
        return 0;
    }
    
    if (x < 0 || x >= matrixWidth ||
        y < 0 || y >= matrixHeight)
    {
        // out of bounds
        return 0;
    }
    
    return buffer[y*matrixWidth + x];   
}

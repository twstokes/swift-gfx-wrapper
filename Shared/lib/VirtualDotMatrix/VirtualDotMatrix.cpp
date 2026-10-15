#include "VirtualDotMatrix.hpp"
#include <algorithm>

VirtualDotMatrix::VirtualDotMatrix(int16_t mW, int16_t mH, bool useBuffer)
    : Adafruit_GFX(mW, mH), buffer(NULL), drawPixelCallback(NULL), swiftBoard(NULL) {
        if (useBuffer) {
            // initialize an internal pixel buffer
            buffer = new uint16_t[size_t(mW) * mH]();
        }
}

/*
    set the drawing callbacks (if provided) and fill the screen with black
*/
void VirtualDotMatrix::start(const void * sb = NULL, DrawPixelCallback cb = NULL)
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
    if (x < 0 || x >= width() ||
        y < 0 || y >= height())
    {
        // out of bounds
        return;
    }

    // using a buffer can impact performance positively by doing quick lookups
    if (buffer != NULL) {
        if (buffer[pixelIndex(x, y)] == color) {
            // nothing changed, early return
            return;
        }

        buffer[pixelIndex(x, y)] = color;
        ++revision;
    }

    if (callbacksEnabled && drawPixelCallback != NULL && swiftBoard != NULL) {
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

    if (x < 0 || x >= width() ||
        y < 0 || y >= height())
    {
        // out of bounds
        return 0;
    }

    return buffer[pixelIndex(x, y)];
}

VirtualDotMatrix::~VirtualDotMatrix() {
    delete[] buffer;
}

void VirtualDotMatrix::fillScreen(uint16_t color) {
    fillRect(0, 0, width(), height(), color);
}

void VirtualDotMatrix::fillRect(int16_t x, int16_t y, int16_t w, int16_t h, uint16_t color) {
    // Retain the legacy callback traversal order when callbacks are enabled.
    if (callbacksEnabled || !buffer) {
        Adafruit_GFX::fillRect(x, y, w, h, color);
        return;
    }
    // The bundled GFX implementation draws reversed lines for h <= 0.
    // Also preserve its int16_t endpoint conversion for oversized spans.
    if (h <= 0 || int(x) + w > INT16_MAX || int(y) + h - 1 > INT16_MAX) {
        Adafruit_GFX::fillRect(x, y, w, h, color);
        return;
    }
    if (w <= 0) return;
    const int left = std::max(0, int(x));
    const int top = std::max(0, int(y));
    const int right = std::min(int(width()), int(x) + w);
    const int bottom = std::min(int(height()), int(y) + h);
    if (left >= right || top >= bottom) return;
    int rawLeft = left, rawTop = top, rawRight = right, rawBottom = bottom;
    switch (rotation) {
    case 1:
        rawLeft = WIDTH - bottom; rawRight = WIDTH - top;
        rawTop = left; rawBottom = right;
        break;
    case 2:
        rawLeft = WIDTH - right; rawRight = WIDTH - left;
        rawTop = HEIGHT - bottom; rawBottom = HEIGHT - top;
        break;
    case 3:
        rawLeft = top; rawRight = bottom;
        rawTop = HEIGHT - right; rawBottom = HEIGHT - left;
        break;
    }
    if (rawLeft == 0 && rawRight == WIDTH) {
        std::fill(buffer + rawTop * WIDTH, buffer + rawBottom * WIDTH, color);
    } else {
        for (int row = rawTop; row < rawBottom; ++row) {
            std::fill(buffer + row * WIDTH + rawLeft, buffer + row * WIDTH + rawRight, color);
        }
    }
    ++revision;
}

void VirtualDotMatrix::drawFastHLine(int16_t x, int16_t y, int16_t w, uint16_t color) {
    if (callbacksEnabled || !buffer || w <= 0 || int(x) + w - 1 > INT16_MAX) Adafruit_GFX::drawFastHLine(x, y, w, color);
    else fillRect(x, y, w, 1, color);
}

void VirtualDotMatrix::drawFastVLine(int16_t x, int16_t y, int16_t h, uint16_t color) {
    if (callbacksEnabled || !buffer || h <= 0 || int(y) + h - 1 > INT16_MAX) Adafruit_GFX::drawFastVLine(x, y, h, color);
    else fillRect(x, y, 1, h, color);
}

namespace {
inline void writeRGBA(uint16_t color, uint8_t *destination) {
    const uint8_t r = (color >> 11) & 31;
    const uint8_t g = (color >> 5) & 63;
    const uint8_t b = color & 31;
    destination[0] = (r << 3) | (r >> 2);
    destination[1] = (g << 2) | (g >> 4);
    destination[2] = (b << 3) | (b >> 2);
    destination[3] = 255;
}
}

void VirtualDotMatrix::copyRGBA(uint8_t *destination) const {
    const size_t count = size_t(WIDTH) * HEIGHT;
    if (!buffer) {
        for (size_t i = 0; i < count; ++i) writeRGBA(0, destination + 4 * i);
    } else if (rotation == 0) {
        // Contiguous loop allows the compiler to vectorize RGB565 expansion.
        for (size_t i = 0; i < count; ++i) writeRGBA(buffer[i], destination + 4 * i);
    } else {
        for (int16_t y = 0; y < height(); ++y) {
            for (int16_t x = 0; x < width(); ++x) {
                writeRGBA(buffer[pixelIndex(x, y)], destination);
                destination += 4;
            }
        }
    }
}

size_t VirtualDotMatrix::pixelIndex(int16_t x, int16_t y) const {
    int16_t t;
    switch (rotation) {
    case 1: t = x; x = WIDTH - 1 - y; y = t; break;
    case 2: x = WIDTH - 1 - x; y = HEIGHT - 1 - y; break;
    case 3: t = x; x = y; y = HEIGHT - 1 - t; break;
    }
    return size_t(y) * WIDTH + x;
}

void VirtualDotMatrix::setRotation(uint8_t r) {
    const uint8_t previous = rotation;
    Adafruit_GFX::setRotation(r);
    if (rotation != previous) ++revision;
}

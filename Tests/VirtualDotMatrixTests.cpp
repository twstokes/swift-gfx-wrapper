#include "VirtualDotMatrix.hpp"
#include "Fonts/FreeSans9pt7b.h"
#include <algorithm>
#include <array>
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <random>
#include <vector>

using PixelWrite = std::array<int, 3>;
static const void recordCallback(int16_t x, int16_t y, uint16_t color, const void *context) {
    auto &writes = *static_cast<std::vector<PixelWrite> *>(const_cast<void *>(context));
    writes.push_back({x, y, color});
}

// Uses the unoptimized Adafruit primitives and GFXcanvas16 pixel rotation.
class ReferenceMatrix : public Adafruit_GFX {
public:
    ReferenceMatrix(int16_t w, int16_t h) : Adafruit_GFX(w, h), pixels(size_t(w) * h) {}
    void drawPixel(int16_t x, int16_t y, uint16_t c) override {
        if (x < 0 || y < 0 || x >= width() || y >= height()) return;
        const int16_t logicalX = x, logicalY = y;
        int16_t t;
        switch (rotation) {
        case 1: t = x; x = WIDTH - 1 - y; y = t; break;
        case 2: x = WIDTH - 1 - x; y = HEIGHT - 1 - y; break;
        case 3: t = x; x = y; y = HEIGHT - 1 - t; break;
        }
        auto &pixel = pixels[size_t(y) * WIDTH + x];
        if (recordWrites && pixel != c) writes.push_back({logicalX, logicalY, c});
        pixel = c;
    }
    std::vector<uint16_t> pixels;
    std::vector<PixelWrite> writes;
    bool recordWrites = true;
};

static void require(bool condition, const char *message) {
    if (!condition) { std::cerr << message << '\n'; std::exit(1); }
}

static void compare(VirtualDotMatrix &matrix, const ReferenceMatrix &reference) {
    std::vector<uint8_t> rgba(reference.pixels.size() * 4);
    matrix.copyRGBA(rgba.data());
    // Snapshot is in logical coordinates, including after rotation.
    for (int y = 0; y < matrix.height(); ++y) {
        for (int x = 0; x < matrix.width(); ++x) {
            int rx = x, ry = y;
            switch (matrix.getRotation()) {
            case 1: rx = 37 - 1 - y; ry = x; break;
            case 2: rx = 37 - 1 - x; ry = 23 - 1 - y; break;
            case 3: rx = y; ry = 23 - 1 - x; break;
            }
            const uint16_t c = reference.pixels[size_t(ry) * 37 + rx];
            require(matrix.getPixel(x, y) == c, "Adafruit pixel mismatch");
            const size_t i = (size_t(y) * matrix.width() + x) * 4;
            const unsigned r = (c >> 11) & 31, g = (c >> 5) & 63, b = c & 31;
            require(rgba[i] == ((r << 3) | (r >> 2)) &&
                    rgba[i+1] == ((g << 2) | (g >> 4)) &&
                    rgba[i+2] == ((b << 3) | (b >> 2)) && rgba[i+3] == 255,
                    "RGBA snapshot mismatch");
        }
    }
}

static void compatibility(bool callbacks) {
    VirtualDotMatrix matrix(37, 23, true);
    std::vector<PixelWrite> writes;
    matrix.start(&writes, recordCallback);
    matrix.setDrawCallbacksEnabled(callbacks);
    ReferenceMatrix reference(37, 23);
    std::mt19937 random(42);
    for (int rotation = 0; rotation < 4; ++rotation) {
        matrix.setRotation(rotation); reference.setRotation(rotation);
        compare(matrix, reference);
        for (int i = 0; i < 1500; ++i) {
            const int16_t x = int(random() % 70) - 20, y = int(random() % 55) - 15;
            const int16_t w = int(random() % 50) - 5, h = int(random() % 40) - 5;
            const uint16_t c = random();
            switch (i % 16) {
            case 0: matrix.fillRect(x,y,w,h,c); reference.fillRect(x,y,w,h,c); break;
            case 1: matrix.drawFastHLine(x,y,w,c); reference.drawFastHLine(x,y,w,c); break;
            case 2: matrix.drawFastVLine(x,y,h,c); reference.drawFastVLine(x,y,h,c); break;
            case 3: matrix.drawLine(x,y,w,h,c); reference.drawLine(x,y,w,h,c); break;
            case 4: matrix.fillCircle(x,y,7,c); reference.fillCircle(x,y,7,c); break;
            case 5: matrix.fillTriangle(x,y,w,h,15,12,c); reference.fillTriangle(x,y,w,h,15,12,c); break;
            case 6: matrix.fillRoundRect(x,y,19,15,4,c); reference.fillRoundRect(x,y,19,15,4,c); break;
            case 7: matrix.drawRect(x,y,19,15,c); reference.drawRect(x,y,19,15,c); break;
            case 8: matrix.drawChar(x,y,'A',c,0,2); reference.drawChar(x,y,'A',c,0,2); break;
            case 9: matrix.fillScreen(c); reference.fillScreen(c); break;
            case 10: matrix.writeFillRect(x,y,w,h,c); reference.writeFillRect(x,y,w,h,c); break;
            case 12: {
                const uint8_t bitmap[] = {0xAA,0x55,0xF0,0x0F};
                matrix.drawBitmap(x,y,bitmap,8,4,c,0);
                reference.drawBitmap(x,y,bitmap,8,4,c,0); break;
            }
            case 13: {
                uint16_t bitmap[] = {0xF800,0x07E0,0x001F,0xFFFF,0,0x1234};
                matrix.drawRGBBitmap(x,y,bitmap,3,2);
                reference.drawRGBBitmap(x,y,bitmap,3,2); break;
            }
            case 14: {
                const uint16_t bitmap[] = {0xF800,0x07E0,0x001F,0xFFFF,0,0x1234};
                const uint8_t mask[] = {0xA0,0x60};
                matrix.drawRGBBitmap(x,y,bitmap,mask,3,2);
                reference.drawRGBBitmap(x,y,bitmap,mask,3,2); break;
            }
            case 15: {
                const uint8_t bitmap[] = {0,64,128,192,255,16};
                matrix.drawGrayscaleBitmap(x,y,bitmap,3,2);
                reference.drawGrayscaleBitmap(x,y,bitmap,3,2); break;
            }
            case 11:
                matrix.setFont(&FreeSans9pt7b); reference.setFont(&FreeSans9pt7b);
                matrix.setCursor(x,y); reference.setCursor(x,y);
                matrix.write('G'); reference.write('G');
                matrix.setFont(nullptr); reference.setFont(nullptr); break;
            }
            compare(matrix, reference);
            if (callbacks) require(writes == reference.writes, "Callback order/content mismatch");
            writes.clear(); reference.writes.clear();
        }
    }
    const auto revision = matrix.frameRevision();
    matrix.drawPixel(0, 0, matrix.getPixel(0, 0));
    matrix.drawPixel(-1, -1, 123);
    require(matrix.frameRevision() == revision, "No-op pixel writes changed revision");
    matrix.setRotation((matrix.getRotation() + 1) % 4);
    require(matrix.frameRevision() != revision, "Rotation did not invalidate snapshot");
}

static const void callback(int16_t, int16_t, uint16_t, const void *context) {
    ++*static_cast<size_t *>(const_cast<void *>(context));
}

template <typename Matrix> static double benchmark(Matrix &matrix, int workload) {
    const int iterations = 3000;
    const auto start = std::chrono::steady_clock::now();
    for (int i = 0; i < iterations; ++i) {
        matrix.fillScreen(i & 1 ? 0 : 0xffff);
        if (workload == 1) {
            matrix.fillTriangle(0,0,128,110,255,0,0xf800);
            matrix.fillCircle(128,64,50,0x07e0);
            matrix.fillRoundRect(15,15,200,90,10,0x001f);
        } else if (workload == 2) {
            matrix.setCursor(i % 256 - 80,40);
            matrix.setTextSize(2);
            matrix.print("Hello Adafruit!");
        }
    }
    return std::chrono::duration<double, std::micro>(std::chrono::steady_clock::now() - start).count() / iterations;
}

int main() {
    compatibility(false); compatibility(true);
    VirtualDotMatrix buffered(4, 3, true);
    size_t calls = 0;
    buffered.start(&calls, callback);
    buffered.drawPixel(1, 1, 123); buffered.drawPixel(1, 1, 123);
    require(calls == 1, "Changed-pixel callback behavior changed");
    buffered.setDrawCallbacksEnabled(false);
    buffered.fillScreen(456);
    require(calls == 1, "Disabled callbacks fired");
    buffered.setDrawCallbacksEnabled(true);
    buffered.drawPixel(1, 1, 789);
    require(calls == 2, "Callbacks failed to resume");
    VirtualDotMatrix unbuffered(4,3,false);
    unbuffered.start(&calls, callback);
    unbuffered.drawPixel(1,1,123); unbuffered.drawPixel(1,1,123);
    require(calls == 16, "Unbuffered callback behavior changed");
    std::cout << "Compatibility passed: 12,000 drawing operations, all rotations, RGBA and callbacks.\n";
    ReferenceMatrix reference(256,128);
    reference.recordWrites = false;
    VirtualDotMatrix fast(256,128,true);
    fast.setDrawCallbacksEnabled(false);
    const char *names[] = {"fillScreen", "filled shapes", "scrolling text"};
    for (int workload = 0; workload < 3; ++workload) {
        const double baseline = benchmark(reference, workload), optimized = benchmark(fast, workload);
        std::cout << names[workload] << ": reference " << baseline << " us/frame, optimized "
                  << optimized << " us/frame, " << baseline / optimized << "x\n";
    }
    std::vector<uint8_t> rgba(256 * 128 * 4);
    const auto start = std::chrono::steady_clock::now();
    for (int i = 0; i < 3000; ++i) fast.copyRGBA(rgba.data());
    std::cout << "RGBA conversion: " << std::chrono::duration<double, std::micro>(
        std::chrono::steady_clock::now() - start).count() / 3000 << " us/frame\n";

}

#pragma once

#define EXPORT //extern "C" __declspec (dllexport)

const BYTE MAXCHANNEL = 255;
const int MAXCHANNELSQ = 255*255;

struct Pixel
{
	BYTE blue;
	BYTE green;
	BYTE red;
	BYTE alpha;
};

struct Bitmap
{
	long width;
	long height;
	Pixel* pAddress;
	Bitmap(unsigned objectID, long _width, long _height);
	inline bool IsValid(long x, long y);
	inline Pixel* PPixel(long x, long y);
};



EXPORT int add2(int num);

EXPORT unsigned BitmapAddress(unsigned objectID);
EXPORT void _stdcall BlendBlt(
	unsigned destObjectID, long destBmpWidth, long destBmpHeight,
	long destX, long destY, 
	unsigned srcObjectID, long srcBmpWidth, long srcBmpHeight,
	long srcX, long srcY, long srcWidth, long srcHeight,
	long blendType, BYTE opacity);

inline void AlphaBlend(BYTE& result, BYTE& dest, BYTE& src)
{
	result = (src * src + dest * (MAXCHANNEL - src)) / MAXCHANNEL;
}

inline void Multiply(Pixel* pDest, Pixel* pSrc, BYTE opacity)
{
	float sa = (float) pSrc->alpha * opacity / MAXCHANNELSQ;
	pDest->red = sa * (pDest->red * pSrc->red / MAXCHANNEL - pDest->red) +
		 pDest->red;
	pDest->blue= sa * (pDest->blue * pSrc->blue / MAXCHANNEL - pDest->blue) +
		pDest->blue;
	pDest->green = sa * (pDest->green * pSrc->green / MAXCHANNEL - pDest->green) +
		pDest->green;
}

inline void Clamp(long& value, long min, long max);
inline bool IsBetween(long value, long min, long max);
inline bool Intersect(long minx1, long miny1, long maxx1, long maxy1,
					  long minx2, long miny2, long maxx2, long maxy2,
					  long& minxresult, long& minyresult, long& maxxresult, long& maxyresult);
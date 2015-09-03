// YABL.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "YABL.h"

Bitmap::Bitmap(unsigned objectID, long _width, long _height)
{
	pAddress = (Pixel*)BitmapAddress(objectID);
	width = _width;
	height = _height;
}

bool Bitmap::IsValid(long x, long y)
{
	return IsBetween(x, 0, width) && IsBetween(y, 0, height);
}

Pixel* Bitmap::PPixel(long x, long y)
{
	return (Pixel*)(pAddress + (height - y - 1) * width + x);
}


int add2(int num){
   return num + 2;
}

unsigned BitmapAddress(unsigned objectID)
{
	return *(*(*(unsigned***)(objectID*2+16) + 2) + 4);
}

EXPORT void _stdcall BlendBlt(
	unsigned destObjectID, long destBmpWidth, long destBmpHeight,
	long destx, long desty, 
	unsigned srcObjectID, long srcBmpWidth, long srcBmpHeight,
	long srcx, long srcy, long srcWidth, long srcHeight,
	long blendType, BYTE opacity)
{
	long srcminx, srcminy, srcmaxx, srcmaxy;
	long destminx, destminy, destmaxx, destmaxy;
	Bitmap dest(destObjectID, destBmpWidth, destBmpHeight);
	Bitmap src(srcObjectID, srcBmpWidth, srcBmpHeight);

	if (!Intersect(0, 0, srcBmpWidth - 1, srcBmpHeight - 1,
			srcx, srcy, srcx + srcWidth - 1, srcy + srcHeight - 1,
			srcminx, srcminy, srcmaxx, srcmaxy))
		return; // source rect out of range

	if (!Intersect(srcx - destx, srcy - desty, srcx - destx + destBmpWidth - 1, srcy - desty + destBmpHeight - 1,
			srcminx, srcminy, srcmaxx, srcmaxy,
			destminx, destminy, destmaxx, destmaxy))
		return ; // dest rect out of range

	for (long y = 0; destminy + y <= destmaxy; y++)
	{
		for (long x = 0; destminx + x <= destmaxx; x++)
		{
			Multiply(dest.PPixel(x + destx + destminx - srcx, y + desty + destminy - srcy),
				src.PPixel(x + destminx, y + destminy),
				opacity);
		}
	}

	//long dx, dy, sx, sy;
	//for (int x = 0; x < srcWidth; x++)
	//{
	//	dx = destx + x;
	//	sx = srcx + x;
	//	for (int y = 0; y < srcHeight; y++)
	//	{
	//		dy = desty + y;
	//		sy = srcy + y;
	//		if (dest.IsValid(dx, dy) && src.IsValid(sx, sy))
	//		{
	//			Multiply(dest.PPixel(dx,dy), src.PPixel(sx,sy), opacity);
	//		}
	//	}
	//}
}

void Clamp(long& value, long min, long max)
{
	if (value < min)
		value = min;
	else if (value > max)
		value = max;
}

bool IsBetween(long value, long min, long max)
{
	return value >= min && value < max;
}

bool Intersect(long minx1, long miny1, long maxx1, long maxy1,
			   long minx2, long miny2, long maxx2, long maxy2,
			   long& minxresult, long& minyresult, long& maxxresult, long& maxyresult)
{
	minx1 > minx2 ? minxresult = minx1 : minxresult = minx2;
	miny1 > miny2 ? minyresult = miny1 : minyresult = miny2;
	maxx1 < maxx2 ? maxxresult = maxx1 : maxxresult = maxx2;
	maxy1 < maxy2 ? maxyresult = maxy1 : maxyresult = maxy2;
	return (maxxresult >= minxresult && maxyresult >= minyresult);
}
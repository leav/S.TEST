#include <windows.h>

struct Bitmap {
	short width;
	short height;
	unsigned id;
	unsigned *bits;
};

/*
 * bits address = MEM[MEM[MEM[rb_object_id * 2 + 16] + 8] + 16]
 */
void __stdcall seek(Bitmap &bitmap) {
	unsigned *&bits = bitmap.bits;
	if(0 == bits) {
		bits = (unsigned *)((bitmap.id << 1) + 16);
		bits = (unsigned *)(*bits + 8);
		bits = (unsigned *)(*bits + 16);
		bits = (unsigned *)*bits;
	}
}

short inline __stdcall abs(short &x) {
	return x < 0 ? -x : x;
}
/*
float inline __stdcall abs(float &x) {
	return x < 0 ? -x : x;
}
*/

short __stdcall Round(double x) {
	return (int) x + (x + 0.5 >= x ? 1 : 0);
}

void __stdcall swap(short &x, short &y) {
	x ^= y;
	y ^= x;
	x ^= y;
}

void inline __stdcall plot(short x, short y, unsigned &clr, Bitmap &bitmap) {
//	*(bitmap.bits + (bitmap.height-y-1)*bitmap.width + x) = clr;
	int alpha = 
}

void __stdcall DrawLine(register short x1, register short y1, register short x2, short y2, unsigned &clr, Bitmap &bitmap) {
	register bool steep;
	register char step;
	register short dx, dy;
	register int err;
	seek(bitmap);
	dx = abs(x2 - x1);
	dy = abs(y2 - y1);
	steep = dy > dx;
	if(steep) {
		swap(x1, y1);
		swap(x2, y2);
	}
	if(x1 > x2) {
		swap(x1, x2);
		swap(y1, y2);
	}
	step = y1 < y2 ? 1 : -1;
	if(steep) {
		err = dy/2;
		for(; x1 <= x2; ++x1) {
			plot(y1, x1, clr, bitmap);
			err -= dx;
			if(err < 0) {
				y1 += step;
				err += dy;
			}
		}
	} else {
		err = dx/2;
		for(; x1 <= x2; ++x1) {
			plot(x1, y1, clr, bitmap);
			err -= dy;
			if(err < 0) {
				y1 += step;
				err += dx;
			}
		}
	}
}

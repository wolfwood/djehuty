/*
 * color.d
 *
 * This file implements the Scaffold for platform specific Color for Windows.
 *
 * Author: Dave Wilkinson
 *
 */

module platform.win.scaffolds.color;

import platform.win.vars;
import platform.win.common;
import platform.win.main;

import core.view;
import core.graphics;
import core.string;
import core.file;
import core.color;

import core.main;

import core.definitions;

void ColorGetSystemColor(ref Color clr, SystemColor sysColorIndex)
{
	switch (sysColorIndex)
	{
		case SystemColor.Window:
			ColorSetValue(clr, (GetSysColor(15)));
			break;
		default: break;
	}
}


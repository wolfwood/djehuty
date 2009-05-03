module core.main;

extern(System) void DjehutyMain();

import core.basewindow;
import core.window;
import core.string;

import console.window;
import console.main;

import core.thread;

import platform.imports;
mixin(PlatformScaffoldImport!());
mixin(PlatformGenericImport!("definitions"));
mixin(PlatformGenericImport!("console"));
mixin(PlatformGenericImport!("vars"));

void DjehutyStart()
{
	DjehutyMain();

	if (!Djehuty._hasStarted)
	{
		Scaffold.AppStart();
		Djehuty._hasStarted = true;
	}

	if (Djehuty._windowCount == 0 && Djehuty._console_inited == false)
	{
		DjehutyEnd();
	}
}

void DjehutyEnd()
{
	// Tell all running threads that they should end to allow shutdown to commense
	foreach(th; Djehuty._threads)
	{
		th.pleaseStop();
	}

	Scaffold.AppEnd();
}

// Section: Core

// Description: This class is the main class for the framework.  You should construct one within DjehutyMain() and then use this to add windows.
class Djehuty
{
	public:

		// Description: Will add and create the window (as long as it hasn't been already) and add it to the root window hierarchy.
		// window: An instance of a BaseWindow class, or any the inherit from BaseWindow.
		static void addWindow(BaseWindow window)
		{
			WindowPlatformVars* wpv = WindowGetPlatformVars(window);

			synchronized {
				// update the window linked list
				UpdateWindowList(window);

				// increase global window count
				_windowCount++;

				// create the window through platform calls
				Scaffold.WindowCreate(window, wpv);

			}

			if (window.getVisibility())
			{
				Scaffold.WindowSetVisible(window, wpv, true);
			}
		}

		// Description: Will initialize the console and set the current console window to be the one specified.
		// window: An instance of a ConsoleWindow class that will set up a context and replace any that had previously been set.
		static void setConsoleWindow(ConsoleWindow window)
		{
			if (!_console_inited)
			{
				//ConsoleInit();

				_console_inited = true;
			}

			_curConsoleWindow = window;

			// Draw Window
			ConsoleWindowOnSet(_curConsoleWindow);
		}

	private:
		static BaseWindow _windowListHead = null;
		static BaseWindow _windowListTail = null;

		static int _windowCount;
		static int _windowVisibleCount;

		static bool _console_inited = false;

		static ConsoleWindow _curConsoleWindow;

		static bool _hasStarted = false;

		static Thread[] _threads;

}

void RegisterThread(ref Thread thread)
{
	Djehuty._threads ~= thread;
}

void UnregisterThread(ref Thread thread)
{
	synchronized
	{
		foreach(i,th; Djehuty._threads)
		{
			if (th is thread)
			{
				Djehuty._threads = Djehuty._threads[0..i] ~ Djehuty._threads[i+1..$];
			}
		}
	}
}